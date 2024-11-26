//
//  InheritedCodableImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/8.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct InheritedCodable: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw MacroError(text: "`@InheritedCodable` must be used on a subclass.")
        }
        let typeInfo = try TypeInfo(decl: declaration, context: context)
        let decoder = try typeInfo.generateDecoderInit(isOverride: true)
        let encoder = try typeInfo.generateEncoderFunc(isOverride: true)
        return [decoder, encoder]
    }
}
