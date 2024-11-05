import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Codable {}

extension Codable: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard
            declaration.as(StructDeclSyntax.self) != nil
            || declaration.as(ClassDeclSyntax.self) !=  nil 
        else {
            throw MacroError.onlyForStructOrClass
        }
        
        if let inheritedType = declaration.inheritanceClause?.inheritedTypes,
           inheritedType.contains(where: { $0.type.trimmedDescription == "Codable" }) {
            return []
        }
        let extensionDecl: DeclSyntax =
            """
            extension \(type.trimmed): Codable {}
            """
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
}

extension Codable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let typeInfo = try TypeInfo(decl: declaration, context: context)
        let decoder = try typeInfo.generateDecoderInit()
        let encoder = try typeInfo.generateEncoderFunc()
        
        var hasMemberwiseInit = true
        if case .argumentList(let list) = node.arguments,
           let item = list.first(where: { $0.label?.text == "memberwiseInit" }),
           item.expression.description == "false" {
            hasMemberwiseInit = false
        }
        var decls = [decoder, encoder]
        if hasMemberwiseInit {
            decls.append(try typeInfo.generateMemberwiseInit())
        }
        return decls
    }
}
