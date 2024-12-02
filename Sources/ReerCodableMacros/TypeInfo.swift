import SwiftSyntax
import SwiftSyntaxMacros

struct AssociatedValue {
    var label: String?
    var type: String
    var index: Int
    var defaultValue: String?
    
    var variableName: String {
        return label ?? "_\(index)"
    }
}

struct AssociatedMatch {
    let label: String?
    let keys: [String]
    let index: String?
}

struct EnumCase {
    var caseName: String
    var rawValue: String
    // [Type: Value]
    var matches: [String: [String]] = [:]
    var associatedMatch: [AssociatedMatch] = []
    var associated: [AssociatedValue] = []
    
    var initText: String {
        let associated = "\(associated.compactMap { "\($0.label == nil ? $0.variableName : "\($0.variableName): \($0.variableName)")" }.joined(separator: ","))"
        let postfix = associated.isEmpty ? "\(associated)" : "(\(associated))"
        return """
            .\(caseName)\(postfix)
            """
    }
}

struct TypeInfo {
    let context: MacroExpansionContext
    let decl: DeclGroupSyntax
    var isEnum = false
    var enumRawType: String?
    var enumCases: [EnumCase] = []
    var caseStyles: [CaseStyle] = []
    var properties: [PropertyInfo] = []
    
    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        if let enumDecl = decl.as(EnumDeclSyntax.self) {
            self.isEnum = true
            let availableRawTypes = [
                "Int", "Int8", "Int16", "Int32", "Int64",
                "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
                "String", "Float", "Double"
            ]
            if let rawTypeName = enumDecl.inheritanceClause?.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self)?.name.trimmedDescription,
               availableRawTypes.contains(rawTypeName) {
                enumRawType = rawTypeName
            }
            
            var index = 0
            var lastRawValue: Double = 0.0
            try enumDecl.memberBlock.members.forEach {
                try $0.decl.as(EnumCaseDeclSyntax.self)?.elements.forEach { caseElement in
                    let name = caseElement.name.trimmedDescription
                    var raw: String
                    if let rawValue = caseElement.rawValue?.value.trimmedDescription {
                        raw = rawValue
                        lastRawValue = Double(raw)!
                    } else if let enumRawType {
                        switch enumRawType {
                        case "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
                            raw = if index == 0 { "0" } else { String(Int(lastRawValue) + 1) }
                            lastRawValue = Double(raw)!
                        case "String":
                            raw = name
                        case "Double", "Float":
                            raw = if index == 0 { "0.0" } else { String(Double(lastRawValue) + 1) }
                        default:
                            throw MacroError(text: "Can not handle enum raw type: \(enumRawType)")
                        }
                    } else {
                        raw = "\"\(name)\""
                    }
                    var associated: [AssociatedValue] = []
                    var paramIndex = 0
                    caseElement.parameterClause?.parameters.forEach {
                        let label = $0.firstName?.trimmedDescription
                        let type = $0.type.trimmedDescription
                        let defaultValue = $0.defaultValue?.value.trimmedDescription
                        associated.append(.init(label: label, type: type, index: paramIndex, defaultValue: defaultValue))
                        paramIndex += 1
                    }
                    enumCases.append(.init(caseName: name, rawValue: raw, associated: associated))
                    index += 1
                }
                
                if let attribute = $0.decl.as(EnumCaseDeclSyntax.self)?.attributes.first?.as(AttributeSyntax.self),
                   attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.trimmedDescription == "CodingCase" {
                    if let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) {
                        arguments.forEach {
                            if $0.label?.trimmedDescription == "match",
                               let matchString = $0.expression.as(FunctionCallExprSyntax.self)?.trimmedDescription,
                               let tuple = parseEnumCaseMatchString(matchString) {
                                var last = enumCases.removeLast()
                                var values = last.matches[tuple.type] ?? []
                                values.append(tuple.value)
                                last.matches[tuple.type] = values
                                enumCases.append(last)
                            }
                            if $0.label?.trimmedDescription == "values",
                               let values = $0.expression.as(ArrayExprSyntax.self) {
                                let valueMatches = values.elements.compactMap { match in
                                    if let expression = match.expression.as(FunctionCallExprSyntax.self) {
                                        
                                        var label: String?
                                        var indexArg: String?
                                        var keys: [String] = []
                                        for arg in expression.arguments {
                                            if arg.label?.trimmedDescription == "label" {
                                                label = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription
                                            }
                                            else if arg.label?.trimmedDescription == "index" {
                                                indexArg = arg.expression.as(IntegerLiteralExprSyntax.self)?.trimmedDescription
                                            }
                                            else if let keyArg = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription {
                                                keys.append(keyArg)
                                            }
                                        }
                                        return AssociatedMatch(label: label, keys: keys, index: indexArg)
                                    } else {
                                        return nil
                                    }
                                }
                                var last = enumCases.removeLast()
                                last.associatedMatch = valueMatches
                                enumCases.append(last)
                            }
                        }
                    }
                }
            }
        }
        try validateEnumCases(enumCases)
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
                
                if let customCoding = variable.attributes.firstAttribute(named: "CustomCoding"),
                   let attribute = customCoding.as(AttributeSyntax.self),
                   let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) {
                    print(attribute)
                    property.customDecoder = arguments
                        .first(where: { $0.label?.identifier?.name == "decode" })?
                        .expression.trimmedDescription
                    
                    property.customEncoder = arguments
                        .first(where: { $0.label?.identifier?.name == "encode" })?
                        .expression.trimmedDescription
                    
                    if property.customDecoder == nil, property.customEncoder == nil {
                        property.customByType = arguments.trimmedDescription
                    }
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
    // .int(8) -> (Int, 8)
    func parseEnumCaseMatchString(_ string: String) -> (type: String, value: String)? {
        let cleaned = string.trimmingCharacters(in: .whitespaces)
        
        guard
            let range = cleaned.range(of: "("),
            let endRange = cleaned.range(of: ")", options: .backwards)
        else {
            return nil
        }
        
        var typeStr = cleaned[cleaned.index(after: cleaned.startIndex)..<range.lowerBound]
            .trimmingCharacters(in: .whitespaces)
        let valueStr = cleaned[range.upperBound..<endRange.lowerBound]
            .trimmingCharacters(in: .whitespaces)
        
        typeStr = typeStr.prefix(1).uppercased() + typeStr.dropFirst()
        
        return (typeStr, valueStr)
    }
    /*
     @Codable
     enum Phone {
         @CodingCase(match: .bool(true), .int(8), .int(10), .string("youtube"), .string("Apple"))
         case apple
         
         @CodingCase(match: .int(12), .string("MI"), .string("xiaomi"))
         case mi
         case oppo
     }
     
     [
         "Int": [
             ("valueString": "8, 10", "caseName": "apple"),
             ("valueString": "12", "caseName": "mi")
         ],
         "String": [
             ("valueString": "apple", "caseName": "apple"),
             ("valueString": "MI, xiaomi", "caseName": "mi")
         ],
         "Bool": [
             ("valueString": "true", "caseName": "apple")
         ]
     ]
     */
    func processEnumCases(_ enumCases: [EnumCase]) -> [String: [(valueString: String, caseName: String)]] {
        var result: [String: [(String, String)]] = [:]
        
        for enumCase in enumCases {
            for (type, values) in enumCase.matches {
                let caseInfo = (values.joined(separator: ", "), enumCase.caseName)
                if result[type] == nil {
                    result[type] = []
                }
                result[type]?.append(caseInfo)
            }
        }
        
        return result
    }
    
    func validateEnumCases(_ cases: [EnumCase]) throws {
        var matchMap: [String: [String: String]] = [:]
        
        for enumCase in cases {
            for (type, values) in enumCase.matches {
                if matchMap[type] == nil {
                    matchMap[type] = [:]
                }
                
                for value in values {
                    if let existingCase = matchMap[type]?[value] {
                        let error = """
                            Duplicate match found: \(type.lowercased())(\(value)) is used in both cases '\(existingCase)' and '\(enumCase.caseName)'. Matching cases must be mutually exclusive.
                            """
                        throw MacroError(text: error)
                    }
                    matchMap[type]?[value] = enumCase.caseName
                }
            }
        }
    }
}

// MARK: - Generate

extension TypeInfo {
    /// Decode
    func generateDecoderInit(isOverride: Bool = false) throws -> DeclSyntax {
        var shouldAddDidDecode = true
        var assignments: String
        if isEnum {
            assignments = generateEnumDecoderAssignments()
            shouldAddDidDecode = false
        } else {
            assignments = try properties
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
                    // base64
                    if property.base64Coding {
                        let questionMark = property.isOptional ? "?" : ""
                        let uint8 = property.type.hasPrefix("[UInt8]") ? ".re_bytes" : ""
                        body = """
                            {
                                let base64String = try container.decode(type: String\(questionMark).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                                return try base64String\(questionMark).re_base64DecodedData\(uint8)
                            }()
                            """
                    }
                    // Date
                    else if let dateCodingStrategy = property.dateCodingStrategy {
                        body = """
                            container.decodeDate(
                                type: \(property.type).self, 
                                keys: [\(property.codingKeys.joined(separator: ", "))], 
                                strategy: \(dateCodingStrategy)
                            )
                            """
                    }
                    // compact decode
                    else if property.isCompactDecoding {
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
                    }
                    // custom decode
                    else if let customDecoder = property.customDecoder {
                        body = """
                            \(customDecoder)(decoder)
                            """
                    }
                    // custom decode by type
                    else if let customByType = property.customByType {
                        body = """
                            \(customByType).decode(by: decoder)
                            """
                    }
                    // normal
                    else {
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
        }
        
        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        var needRequired = isClass && !isFinal
        if isOverride {
            needRequired = true
        }
        let container = isEnum && !hasEnumAssociatedValue
            ? "let container = try decoder.singleValueContainer()"
            : "let container = try decoder.container(keyedBy: AnyCodingKey.self)"
        let decoder: DeclSyntax = """
        \(raw: needPublic ? "public " : "")\(raw: needRequired ? "required " : "")init(from decoder: Decoder) throws {
            \(raw: container)
            \(raw: assignments)\(raw: isOverride ? "\ntry super.init(from: decoder)" : "")
            \(raw: shouldAddDidDecode ? "try self.didDecode(from: decoder)" : "")
        }
        """
        return decoder
    }
    
    /// Encode
    func generateEncoderFunc(isOverride: Bool = false) throws -> DeclSyntax {
        var encoding: String
        if isEnum {
            encoding = generateEnumEncoderEncoding()
        } else {
            encoding = properties
                .compactMap { property in
                    if property.isIgnored { return nil }
                    let (encodingKey, treatDotAsNested) = if let specifiedEncodingKey = property.encodingKey {
                        (specifiedEncodingKey, property.treatDotAsNestedWhenEncoding)
                    } else {
                        (property.codingKeys.first!, true)
                    }
                    // base64
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
                    }
                    // Date
                    else if let dateCodingStrategy = property.dateCodingStrategy {
                        return """
                        try container.encodeDate(value: self.\(property.name), key: \(encodingKey), treatDotAsNested: \(treatDotAsNested), strategy: \(dateCodingStrategy))
                        """
                    }
                    // custom encode
                    else if let customEncoder = property.customEncoder {
                        return """
                        let _ = try \(customEncoder)(encoder, self.\(property.name))
                        """
                    }
                    // custom encode by type
                    else if let customByType = property.customByType {
                        return """
                        try \(customByType).encode(by: encoder, self.\(property.name))
                        """
                    }
                    // normal
                    else {
                        return "try container.encode(value: self.\(property.name), key: \(encodingKey), treatDotAsNested: \(treatDotAsNested))"
                    }
                }
                .joined(separator: "\n")
        }
        let container = isEnum && !hasEnumAssociatedValue
            ? "var container = encoder.singleValueContainer()"
            : "var container = encoder.container(keyedBy: AnyCodingKey.self)"
        let accessable = if isOpen { "open " } else if isPublic || hasPublicOrOpenProperty { "public " } else { "" }
        let encoder: DeclSyntax = """
        \(raw: accessable)\(raw: isOverride ? "override " : "")func encode(to encoder: Encoder) throws {
            try self.willEncode(to: encoder)
            \(raw: isOverride ? "try super.encode(to: encoder)\n" : "")\(raw: container)
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
    
    private func generateEnumDecoderAssignments() -> String {
        if hasEnumAssociatedValue {
            var index = -1
            let findCase = enumCases.compactMap { theCase in
                index += 1
                return """
                    \(index > 0 ? "else " : "")if let nestedContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("\(theCase.caseName)")) {
                        \(theCase.associated.compactMap { value in
                        var keys: [String] = []
                        if let label = value.label {
                            keys = theCase.associatedMatch.first { $0.label == "\"\(label)\"" }?.keys ?? []
                        } else {
                            keys = theCase.associatedMatch.first { $0.index == "\(value.index)" }?.keys ?? []
                        }
                        keys.append("\"\(value.variableName)\"")
                        keys.removeDuplicates()
                        let hasDefault = value.defaultValue != nil
                        return """
                        let \(value.variableName) = (try\(hasDefault ? "?" : "") nestedContainer.decode(type: \(value.type).self, keys: [\(keys.joined(separator: ", "))]))\(hasDefault ? " ?? (\(value.defaultValue!))" : "")
                        """
                        }.joined(separator: "\n    "))
                        self = \(theCase.initText)
                    } 
                    """
            }.joined(separator: "\n")
            
            return """
                guard container.allKeys.count == 1 else { throw ReerCodableError(text: "Invalid number of keys found, expected one.") }
                \(findCase)
                else {
                    throw ReerCodableError(text: "Key not found for \\(String(describing: Self.self)).")
                }
                """
        } else {
            if enumCases.contains(where: { !$0.matches.isEmpty }) {
                let dict = processEnumCases(enumCases)
                let tryDecode = dict.compactMapWithLastKey("String") { type, caseValues in
                    return """
                        if let value = try? container.decode(\(type).self) {\nswitch value {
                        \(caseValues.compactMap {
                        """
                        case \($0.valueString): self = .\($0.caseName); try self.didDecode(from: decoder); return;
                        """
                        }.joined(separator: "\n"))
                        default: break
                        }
                        }
                        """
                }
                let tryRaw = """
                    let value = try container.decode(type: \(enumRawType ?? "String").self, enumName: String(describing: Self.self))
                    switch value {
                    \(enumCases.compactMap { "case \($0.rawValue): self = .\($0.caseName)" }.joined(separator: "\n"))
                    default: throw ReerCodableError(text: "Cannot initialize \\(String(describing: Self.self)) from invalid value \\(value)")
                    }
                    try self.didDecode(from: decoder)
                    """
                return tryDecode.joined(separator: "\n") + "\n" + tryRaw
            } else {
                return """
                    let value = try container.decode(type: \(enumRawType ?? "String").self, enumName: String(describing: Self.self))
                    switch value {
                    \(enumCases.compactMap { "case \($0.rawValue): self = .\($0.caseName)" }.joined(separator: "\n"))
                    default: throw ReerCodableError(text: "Cannot initialize \\(String(describing: Self.self)) from invalid value \\(value)")
                    }
                    """
            }
        }
    }
    
    private func generateEnumEncoderEncoding() -> String {
        if hasEnumAssociatedValue {
            let encodeCase = """
                \(enumCases.compactMap {
                    let associated = "\($0.associated.compactMap { value in value.variableName }.joined(separator: ","))"
                    let postfix = $0.associated.isEmpty ? "\(associated)" : "(\(associated))"
                    return """
                    case let .\($0.caseName)\(postfix):
                        var nestedContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("\($0.caseName)"))
                        \($0.associated.compactMap { value in
                        """
                        try nestedContainer.encode(\(value.variableName), forKey: AnyCodingKey("\(value.variableName)"))
                        """
                        }.joined(separator: "\n    "))
                    """
                }.joined(separator: "\n"))
                """
            return """
                switch self {
                \(encodeCase)
                }
                """
        } else {
            return """
                switch self {
                \(enumCases.compactMap { "case .\($0.caseName): try container.encode(\($0.rawValue))" }.joined(separator: "\n"))
                }
                """
        }
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
    
    var hasEnumAssociatedValue: Bool {
        return isEnum && enumCases.contains { !$0.associated.isEmpty }
    }
}

extension Dictionary {
    func compactMapWithLastKey<T>(_ lastKey: Key, transform: ((key: Key, value: Value)) throws -> T?) rethrows -> [T] {
        var result: [T] = []
        for (key, value) in self where key != lastKey {
            if let transformed = try transform((key, value)) {
                result.append(transformed)
            }
        }
        
        if let lastValue = self[lastKey],
           let transformed = try transform((lastKey, lastValue)) {
            result.append(transformed)
        }
        
        return result
    }
}

extension Array where Element: Hashable {
    mutating func removeDuplicates() {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}
