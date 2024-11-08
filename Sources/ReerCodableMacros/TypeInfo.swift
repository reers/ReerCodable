import SwiftSyntax
import SwiftSyntaxMacros

struct Property {
    var modifiers: DeclModifierListSyntax = []
    var name: String
    var type: String
    var isOptional = false
    var keys: [String] = []
    var initExpr: String?
    
    var codingKeys: [String] {
        keys.isEmpty
        ? ["\"\(name)\""]
        : keys + ["\"\(name)\""]
    }
}

struct TypeInfo {
    let context: MacroExpansionContext
    let decl: DeclGroupSyntax
    var properties: [Property] = []
    
    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        properties = try parseProperties()
    }
    
    func generateDecoderInit(isOverride: Bool = false) throws -> DeclSyntax {
        let assignments = properties
            .map { property in
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
        }
        """
        return decoder
    }
    
    func generateEncoderFunc(isOverride: Bool = false) throws -> DeclSyntax {
        let encoding = properties
            .map { property in
                return "try container.encode(value: self.\(property.name), key: \(property.codingKeys.first!), isNested: false)"
            }
            .joined(separator: "\n")
        
        let accessable = if isOpen { "open " } else if isPublic || hasPublicOrOpenProperty { "public " } else { "" }
        let encoder: DeclSyntax = """
        \(raw: accessable)\(raw: isOverride ? "override " : "")func encode(to encoder: Encoder) throws {
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
                
                let codingKey = variable.attributes.first(where: {
                    let attribute = $0.as(AttributeSyntax.self)?
                        .attributeName.as(IdentifierTypeSyntax.self)?
                        .trimmedDescription
                    return attribute == "CodingKey"
                })
                if let codingKey {
                    property.keys = codingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .compactMap { $0.expression.trimmedDescription } ?? []
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
