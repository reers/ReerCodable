import SwiftSyntax
import SwiftSyntaxMacros

struct Property {
    var modifiers: DeclModifierListSyntax = []
    var name: String
    var type: String
    var isOptional = false
    var isIgnored = false
    var keys: [String] = []
    var encodingKey: String?
    var treatDotAsNestedWhenEncoding: Bool = true
    var initExpr: String?
    var snakeCase = false
    
    var codingKeys: [String] {
        var result: [String] = keys
        if snakeCase {
            // FIXME: - maybe not from camel case
            result.append("\"\(name.camelToSnake())\"")
        }
        let defaultKey = "\"\(name)\""
        if defaultKey != result.last {
            result.append(defaultKey)
        }
        return result
    }
    
    var defaultValue: String? {
        let trimmed = type.trimmingCharacters(in: .whitespaces)
        if let defaultValue = Self.basicTypeDefaults[trimmed] {
            return defaultValue
        }
        if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
            return ".init()"
        }
        return nil
    }
    
    private static let basicTypeDefaults: [String: String] = [
        "Int": "0",
        "Int8": "0",
        "Int16": "0",
        "Int32": "0",
        "Int64": "0",
        "UInt": "0",
        "UInt8": "0",
        "UInt16": "0",
        "UInt32": "0",
        "UInt64": "0",
        "Bool": "false",
        "String": "\"\"",
        "Float": "0.0",
        "Double": "0.0"
    ]
}

struct TypeInfo {
    let context: MacroExpansionContext
    let decl: DeclGroupSyntax
    var haveSnakeCase = false
    var properties: [Property] = []
    
    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        if decl.attributes.firstAttribute(named: "SnakeCase") != nil {
            haveSnakeCase = true
        }
        properties = try parseProperties()
    }
    
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
                let body = """
                    container.decode(type: \(property.type).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                    """
                if let initExpr = property.initExpr {
                    return "self.\(property.name) = (try? \(body)) ?? (\(initExpr))"
                } else {
                    return "self.\(property.name) = try \(body)"
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
    
    func generateEncoderFunc(isOverride: Bool = false) throws -> DeclSyntax {
        let encoding = properties
            .compactMap { property in
                if property.isIgnored { return nil }
                let (encodingKey, treatDotAsNested) = if let specifiedEncodingKey = property.encodingKey {
                    (specifiedEncodingKey, property.treatDotAsNestedWhenEncoding)
                } else {
                    (property.codingKeys.first!, true)
                }
                return "try container.encode(value: self.\(property.name), key: \(encodingKey), treatDotAsNested: \(treatDotAsNested))"
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

extension TypeInfo {
    func parseProperties() throws -> [Property] {
        return try decl.memberBlock.members.flatMap { member -> [Property] in
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                variable.isStoredProperty
            else {
                return []
            }
            var properties: [Property] = []
            for _ in variable.bindings {
                if variable.isLazy { continue }
                
                guard let type = variable.type else {
                    throw MacroError(text: "Unable to infer the property type. Specify the type explicitly.")
                }
                guard let name = variable.name else {
                    throw MacroError(text: "Macro expansion failed: property requires a name.")
                }
                
                var property = Property(name: name, type: type)
                property.isOptional = variable.isOptional
                property.snakeCase = haveSnakeCase
                if !haveSnakeCase {
                    if variable.attributes.firstAttribute(named: "SnakeCase") != nil {
                        property.snakeCase = true
                    }
                }
                
                if variable.attributes.firstAttribute(named: "IgnoreCoding") != nil {
                    property.isIgnored = true
                }
                
                if let codingKey = variable.attributes.firstAttribute(named: "CodingKey") {
                    property.keys = codingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .compactMap { $0.expression.trimmedDescription } ?? []
                }
                
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
