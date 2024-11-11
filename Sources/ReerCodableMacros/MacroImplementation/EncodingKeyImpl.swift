//
//  EncodingKeyIMPL.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/11.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct EncodingKey: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let name = variable.name
        else {
            return []
        }
        
        let encodingKey = variable.attributes.first(where: {
            let attribute = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            return attribute == "EncodingKey"
        })
        if let encodingKey {
            let inputKeys = encodingKey.as(AttributeSyntax.self)?
                .arguments?.as(LabeledExprListSyntax.self)?
                .compactMap { $0.expression.trimmedDescription } ?? []
            try inputKeys.forEach {
                if $0 == "\"\"" { throw MacroError(text: "Empty encoding key detected of property `\(name)`.") }
            }
        }
        return []
    }
}
