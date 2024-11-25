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
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else {
            throw MacroError(text: "@Codable macro is only for `struct`, `class` or `enum`.")
        }
        
        var codableExisted = false
        if let inheritedType = declaration.inheritanceClause?.inheritedTypes,
           inheritedType.contains(where: { $0.type.trimmedDescription == "Codable" }) {
            codableExisted = true
        }
        let extensionDecl: DeclSyntax =
            """
            extension \(type.trimmed):\(raw: codableExisted ? "" : "Codable,") ReerCodableDelegate {}
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
        let members = declaration.memberBlock.members
        
        for member in members {
            if let initDecl = member.decl.as(InitializerDeclSyntax.self),
               initDecl.signature.parameterClause.parameters.count == 1,
               initDecl.signature.parameterClause.parameters.first?.firstName.text == "from",
               initDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Decoder" {
                throw MacroError(text: "Please use the `@Codable` macro-generated implementation instead of manually implementing `init(from:)`.")
            }
            
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               funcDecl.name.text == "encode" &&
               funcDecl.signature.parameterClause.parameters.count == 1 &&
               funcDecl.signature.parameterClause.parameters.first?.firstName.text == "to" &&
               funcDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Encoder" {
                throw MacroError(text: "Please use the `@Codable` macro-generated implementation instead of manually implementing `encode(to:)`.")
            }
        }
        
        let typeInfo = try TypeInfo(decl: declaration, context: context)
        let decoder = try typeInfo.generateDecoderInit()
        let encoder = try typeInfo.generateEncoderFunc()
        
        var hasMemberwiseInit = true
        if case .argumentList(let list) = node.arguments,
           let item = list.first(where: { $0.label?.text == "memberwiseInit" }),
           item.expression.description == "false" {
            hasMemberwiseInit = false
        }
        /*
        // Only have @Codable for Enum and no @CodingCase case, do nothing.
        if declaration.is(EnumDeclSyntax.self),
           declaration.attributes.containsAttribute(named: "Codable"),
           declaration.attributes.count == 1,
           !declaration.memberBlock.members.contains(where: {
               return $0.decl.as(EnumCaseDeclSyntax.self)?.attributes.containsAttribute(named: "CodingCaseKey") ?? false
           }) {
            return []
        }
         */
        
        var decls = [decoder, encoder]
        if hasMemberwiseInit, !declaration.is(EnumDeclSyntax.self) {
            decls.append(try typeInfo.generateMemberwiseInit())
        }
        return decls
    }
}
