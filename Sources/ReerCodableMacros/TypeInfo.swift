import SwiftSyntax
import SwiftSyntaxMacros

struct TypeInfo {
    let context: MacroExpansionContext
    let decl: DeclGroupSyntax
    var caseStyles: [CaseStyle] = []
    var properties: [PropertyInfo] = []
    
    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        
        caseStyles = decl.attributes.compactMap {
            let attributeId = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            if attributeId == "Codable" { return nil }
            for caseStyle in CaseStyle.allCases {
                if caseStyle.macroName == attributeId {
                    return caseStyle
                }
            }
            return nil
        }
        
        properties = try parseProperties()
    }
}

// MARK: - Parse info

extension TypeInfo {
    func parseProperties() throws -> [PropertyInfo] {
        return try decl.memberBlock.members.flatMap { member -> [PropertyInfo] in
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                variable.isStoredProperty
            else {
                return []
            }
            var properties: [PropertyInfo] = []
            for _ in variable.bindings {
                if variable.isLazy { continue }
                
                guard let type = variable.type else {
                    throw MacroError(text: "Unable to infer the property type. Specify the type explicitly.")
                }
                guard let name = variable.name else {
                    throw MacroError(text: "Macro expansion failed: property requires a name.")
                }
                
                var property = PropertyInfo(name: name, type: type)
                // isOptional
                property.isOptional = variable.isOptional
                // get property case attributes
                let propertyCaseStyles = variable.attributes.compactMap {
                    let attributeId = $0.as(AttributeSyntax.self)?
                        .attributeName.as(IdentifierTypeSyntax.self)?
                        .trimmedDescription
                    for caseStyle in CaseStyle.allCases {
                        if caseStyle.macroName == attributeId {
                            return caseStyle
                        }
                    }
                    return nil
                }
                property.caseStyles = propertyCaseStyles.uniqueMerged(with: caseStyles)
                // ignore coding
                if variable.attributes.firstAttribute(named: "IgnoreCoding") != nil {
                    property.isIgnored = true
                }
                // base64 coding
                if variable.attributes.containsAttribute(named: "Base64Coding") {
                    property.base64Coding = true
                }
                // date coding
                if let dateCoding = variable.attributes.firstAttribute(named: "DateCoding") {
                    property.dateCodingStrategy = dateCoding.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?.trimmedDescription
                }
                
                if variable.attributes.containsAttribute(named: "CompactDecoding") {
                    property.isCompactDecoding = true
                }
                
                // coding key
                if let codingKey = variable.attributes.firstAttribute(named: "CodingKey") {
                    property.keys = codingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .compactMap { $0.expression.trimmedDescription } ?? []
                }
                // encoding key
                if let encodingKey = variable.attributes.firstAttribute(named: "EncodingKey") {
                    property.encodingKey = encodingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .first?.expression.trimmedDescription
                    
                    if let treatDotAsNested = encodingKey.as(AttributeSyntax.self)?
                           .arguments?.as(LabeledExprListSyntax.self)?
                           .first(where: { $0.label?.trimmedDescription == "treatDotAsNested" })?
                           .expression.trimmedDescription,
                       treatDotAsNested == "false" {
                        property.treatDotAsNestedWhenEncoding = false
                    }
                }
                
                property.initExpr = variable.initExpr
                properties.append(property)
            }
            return properties
        }
    }
}

// MARK: - Generate

extension TypeInfo {
    /// Decode
    func generateDecoderInit(isOverride: Bool = false) throws -> DeclSyntax {
        let assignments = try properties
            .compactMap { property in
                if property.isIgnored {
                    if property.isOptional { return nil }
                    if let initExpr = property.initExpr {
                        return "self.\(property.name) = \(initExpr)"
                    } else if let defaultValue = property.defaultValue {
                        return "self.\(property.name) = \(defaultValue)"
                    }
                    throw MacroError(text: "The ignored property `\(property.name)` should have a default value, or be set as an optional type.")
                }
                var body: String
                if property.base64Coding {
                    let questionMark = property.isOptional ? "?" : ""
                    let uint8 = property.type.hasPrefix("[UInt8]") ? ".re_bytes" : ""
                    body = """
                        {
                            let base64String = try container.decode(type: String\(questionMark).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                            return try base64String\(questionMark).re_base64DecodedData\(uint8)
                        }()
                        """
                } else if let dateCodingStrategy = property.dateCodingStrategy {
                    body = """
                        container.decodeDate(
                            type: \(property.type).self, 
                            keys: [\(property.codingKeys.joined(separator: ", "))], 
                            strategy: \(dateCodingStrategy)
                        )
                        """
                } else if property.isCompactDecoding {
                    let propertyType = parseSwiftType(property.type)
                    if propertyType.isArray {
                        body = """
                            container.compactDecodeArray(type: \(property.type.nonOptionalType).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                            """
                    } else if propertyType.isDictionary {
                        body = """
                            container.compactDecodeDictionary(type: \(property.type.nonOptionalType).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                            """
                    } else if propertyType.isSet {
                        body = """
                            {
                                Set(try container.compactDecodeArray(type: [\(property.type.nonOptionalType.setElement)].self, keys: [\(property.codingKeys.joined(separator: ", "))]))
                            }()
                            """
                    } else {
                        throw MacroError(text: "Can not handle property `\(property.name)` with @CompactDecoding.")
                    }
                } else {
                    body = """
                        container.decode(type: \(property.type).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                        """
                }
                
                if let initExpr = property.initExpr {
                    return "self.\(property.name) = (try? \(body)) ?? (\(initExpr))"
                } else {
                    let questionMark = property.isOptional ? "?" : ""
                    return "self.\(property.name) = try\(questionMark) \(body)"
                }
            }
            .joined(separator: "\n")
        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        var needRequired = isClass && !isFinal
        if isOverride {
            needRequired = true
        }
        let decoder: DeclSyntax = """
        \(raw: needPublic ? "public " : "")\(raw: needRequired ? "required " : "")init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: AnyCodingKey.self)
            \(raw: assignments)\(raw: isOverride ? "\ntry super.init(from: decoder)" : "")
            try self.didDecode()
        }
        """
        return decoder
    }
    
    /// Encode
    func generateEncoderFunc(isOverride: Bool = false) throws -> DeclSyntax {
        let encoding = properties
            .compactMap { property in
                if property.isIgnored { return nil }
                let (encodingKey, treatDotAsNested) = if let specifiedEncodingKey = property.encodingKey {
                    (specifiedEncodingKey, property.treatDotAsNestedWhenEncoding)
                } else {
                    (property.codingKeys.first!, true)
                }
                if property.base64Coding {
                    
                    // a Data or Data? type
                    let dataTypeTemp = if property.isOptional {
                        property.type.hasPrefix("[UInt8]") ? "self.\(property.name).map({ Data($0) })" : "self.\(property.name)"
                    } else {
                        property.type.hasPrefix("[UInt8]") ? "Data(self.\(property.name))" : "self.\(property.name)"
                    }
                    
                    return """
                        try {
                            let base64String = \(dataTypeTemp)\(property.questionMark).base64EncodedString()
                            try container.encode(value: base64String, key: \(encodingKey), treatDotAsNested: \(treatDotAsNested))
                        }()
                        """
                } else if let dateCodingStrategy = property.dateCodingStrategy {
                    return """
                        try container.encodeDate(value: self.\(property.name), key: \(encodingKey), treatDotAsNested: \(treatDotAsNested), strategy: \(dateCodingStrategy))
                        """
                } else {
                    return "try container.encode(value: self.\(property.name), key: \(encodingKey), treatDotAsNested: \(treatDotAsNested))"
                }
            }
            .joined(separator: "\n")
        
        let accessable = if isOpen { "open " } else if isPublic || hasPublicOrOpenProperty { "public " } else { "" }
        let encoder: DeclSyntax = """
        \(raw: accessable)\(raw: isOverride ? "override " : "")func encode(to encoder: Encoder) throws {
            try self.willEncode()
            \(raw: isOverride ? "try super.encode(to: encoder)\n" : "")var container = encoder.container(keyedBy: AnyCodingKey.self)
            \(raw: encoding)
        }
        """
        return encoder
    }
    
    /// Init
    func generateMemberwiseInit(isOverride: Bool = false) throws -> DeclSyntax {
        let parameters = properties.map { property in
            var text = property.name
            text += ": \(property.type)"
            if let initExpr = property.initExpr {
                text += "= \(initExpr)"
            } else if property.isIgnored, let defaultValue = property.defaultValue {
                text += "= \(defaultValue)"
            } else if property.isOptional {
                text += "= nil"
            }
            return text
        }

        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        let overrideInit = isOverride ? "super.init()\n" : ""

        let initializer: DeclSyntax = """
        \(raw: needPublic ? "public " : "")init(\(raw: parameters.isEmpty ? "" : "\n")\(raw: parameters.joined(separator: ",\n"))\(raw: parameters.isEmpty ? "" : "\n")) {
            \(raw: overrideInit)\(raw: properties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))
        }
        """
        return initializer
    }
}

// MARK: - Info

extension TypeInfo {
    
    var isClass: Bool {
        return decl.is(ClassDeclSyntax.self)
    }
    
    var isFinal: Bool {
        guard let classDecl = decl.as(ClassDeclSyntax.self) else { return false }
        return classDecl.modifiers.contains { $0.name.text == "final" }
    }
    
    var isPublic: Bool {
        let modifiers = decl.modifiers.compactMap { $0.name.text }
        return modifiers.contains("public")
    }
    
    var isOpen: Bool {
        let modifiers = decl.modifiers.compactMap { $0.name.text }
        return modifiers.contains("open")
    }
    
    var hasPublicOrOpenProperty: Bool {
        return properties.contains { property in
            property.modifiers.contains { $0.name.text == "public" || $0.name.text == "open" }
        }
    }
}
