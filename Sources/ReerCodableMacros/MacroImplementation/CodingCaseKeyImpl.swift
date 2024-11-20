//
//  CodingCaseKeyImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/20.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingCaseKey: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let enumCaseDecl = declaration.as(EnumCaseDeclSyntax.self),
            let name = enumCaseDecl.elements.first?.name.trimmedDescription
        else {
            throw MacroError(text: "@CodingCaseKey macro is only for enum case.")
        }
        if enumCaseDecl.elements.count > 1 {
            throw MacroError(text: "Multiple cases in a single line declaration are not allowed. Please declare each case separately")
        }
        guard
            let caseParam = node.arguments?.as(LabeledExprListSyntax.self)?.first,
            let segments = caseParam.expression.as(StringLiteralExprSyntax.self)?.segments,
            segments.count > 0
        else {
            throw MacroError(text: "Case `\(name)` requires at least one coding case key.")
        }
        return []
    }
}
