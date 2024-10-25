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
    
    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) {
        self.decl = decl
        self.context = context
        properties = parseProperties()
    }
}

extension TypeInfo {
    func parseProperties() -> [Property] {
            return decl.memberBlock.members.flatMap { member -> [Property] in
                guard
                    let variable = member.decl.as(VariableDeclSyntax.self),
                    variable.isStoredProperty
                else {
                    return []
                }
                /*
                var properties: [Property] = []
                
                // 获取修饰符列表
                let modifiers = (variable.modifiers).map { modifier in
                    return modifier.name.text
                }
                variable.type
                for binding in variable.bindings {
                    // 获取属性名
                    guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                        continue
                    }
                    let name = pattern.identifier.text

                    // 获取类型信息
                    var type = ""
                    var isOptional = false

                    if let typeAnnotation = binding.typeAnnotation {
                        let typeSyntax = typeAnnotation.type

                        // 检查是否为可选类型
                        if let optionalType = typeSyntax.as(OptionalTypeSyntax.self) {
                            isOptional = true
                            type = optionalType.wrappedType.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else {
                            type = typeSyntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    } else {
                        type = "Unknown"
                    }

                    // 创建 Property 对象
//                    let property = Property(
//                        modifiers: modifiers,
//                        name: name,
//                        type: type,
//                        isOptional: isOptional,
//                        keys: [],
//                        nestedKeys: []
//                    )
//
//                    properties.append(property)
                }

                return properties
                 */
            }
        }
}
