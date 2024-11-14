//
//  DateCodingImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/14.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DateCoding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self)
        else {
            throw MacroError(text: "@DateCoding macro is only for property.")
        }
        
        if let dateCoding = variable.attributes.firstAttribute(named: "DateCoding") {
            guard let type = variable.type else {
                return []
            }
            guard ["Date", "Date?"].contains(type) else {
                throw MacroError(text: "@DateCoding macro is only for `Date`.")
            }
            
            let param = dateCoding.as(AttributeSyntax.self)?
                .arguments?.as(LabeledExprListSyntax.self)?.trimmedDescription
            if param == nil || param == "" {
                throw MacroError(text: "@DateCoding macro requires a date coding strategy.")
            }
        }
        return []
    }
}
