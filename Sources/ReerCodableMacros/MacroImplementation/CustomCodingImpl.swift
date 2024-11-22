//
//  CustomCodingImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CustomCoding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw MacroError(text: "@CustomCoding macro is only for property.")
        }
        guard variable.attributes.count == 1 else {
            throw MacroError(text: "@CustomCoding macro cannot be used with other attributes.")
        }
        /*
        guard
            node.attributeName.as(IdentifierTypeSyntax.self)?
                .genericArgumentClause?.arguments.first?
                .argument.trimmedDescription == variable.type
        else {
            throw MacroError(text: "@CustomCoding macro requires a generic type declaration.")
        }
         */
        return []
    }
}
