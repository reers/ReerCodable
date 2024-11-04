import SwiftSyntax
import SwiftSyntaxMacros

struct Property {
    var modifiers: DeclModifierListSyntax = []
    var name: String
    var type: String
    var isOptional = false
    var keys: [String] = []
    var nestedKeys: [String] = []
    
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
            for binding in variable.bindings {
                if variable.isLazy { continue }
                
                guard let type = variable.type else {
                    throw MacroError.propertyTypeCanNotBeInferred
                }
                guard let name = variable.name else {
                    throw MacroError.propertyHasNoName
                }
                
                var property = Property(name: name, type: type)
                property.isOptional = variable.isOptional
                
                properties.append(property)
            }
            return properties
        }
    }
}
