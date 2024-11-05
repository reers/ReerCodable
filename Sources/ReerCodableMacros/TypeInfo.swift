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
        let needRequired = isClass && !isFinal
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
                    throw MacroError.propertyTypeCanNotBeInferred
                }
                guard let name = variable.name else {
                    throw MacroError.propertyHasNoName
                }
                
                var property = Property(name: name, type: type)
                property.isOptional = variable.isOptional
                
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
