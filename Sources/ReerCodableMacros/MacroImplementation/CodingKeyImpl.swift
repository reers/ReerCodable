//
//  CodingKeyImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/8.
//


import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingKey: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let name = variable.name
        else {
            throw MacroError(text: "@CodingKey macro is only for property.")
        }
        
        let codingKey = variable.attributes.first(where: {
            let attribute = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            return attribute == "CodingKey"
        })
        if let codingKey {
            let inputKeys = codingKey.as(AttributeSyntax.self)?
                .arguments?.as(LabeledExprListSyntax.self)?
                .compactMap { $0.expression.trimmedDescription } ?? []
            if inputKeys.isEmpty {
                throw MacroError(text: "Property `\(name)` requires at least one coding key.")
            }
            try inputKeys.forEach {
                if $0 == "\"\"" { throw MacroError(text: "Empty coding key detected of property `\(name)`.") }
            }
        }
        return []
    }
}
