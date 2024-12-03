//
//  CodingCaseImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/20.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingCase: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let enumCaseDecl = declaration.as(EnumCaseDeclSyntax.self),
            let name = enumCaseDecl.elements.first?.name.trimmedDescription
        else {
            throw MacroError(text: "@CodingCase macro is only for enum case.")
        }
        if enumCaseDecl.elements.count > 1 {
            throw MacroError(text: "Multiple cases in a single line declaration are not allowed. Please declare each case separately")
        }
        guard let count = node.arguments?.as(LabeledExprListSyntax.self)?.count, count > 0 else {
            throw MacroError(text: "Case `\(name)` requires at least one coding case matcher.")
        }
        try node.arguments?.as(LabeledExprListSyntax.self)?.forEach {
            if ($0.label?.trimmedDescription == "match" || $0.label == nil),
               let functionCall = $0.expression.as(FunctionCallExprSyntax.self),
               functionCall.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.trimmedDescription == "nested",
               let param = functionCall.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.trimmedDescription,
               !param.contains("."){
                throw MacroError(text: ".nested(\(param)) requires its param contains at least one dot `.`")
            }
        }
        
            // .forEach {
//            if ($0.label?.trimmedDescription == "match" || $0.label == nil),
//               let matchString = $0.expression.as(FunctionCallExprSyntax.self)?.trimmedDescription,
//               let tuple = parseEnumCaseMatchString(matchString) {
//                var last = enumCases.removeLast()
//                var values = last.matches[tuple.type] ?? []
//                values.append(tuple.value)
//                last.matches[tuple.type] = values
//                enumCases.append(last)
//            }
//            if $0.label?.trimmedDescription == "values",
//               let values = $0.expression.as(ArrayExprSyntax.self) {
//                let valueMatches = values.elements.compactMap { match in
//                    if let expression = match.expression.as(FunctionCallExprSyntax.self) {
//                        
//                        var label: String?
//                        var indexArg: String?
//                        var keys: [String] = []
//                        for arg in expression.arguments {
//                            if arg.label?.trimmedDescription == "label" {
//                                label = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription
//                            }
//                            else if arg.label?.trimmedDescription == "index" {
//                                indexArg = arg.expression.as(IntegerLiteralExprSyntax.self)?.trimmedDescription
//                            }
//                            else if let keyArg = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription {
//                                keys.append(keyArg)
//                            }
//                        }
//                        return AssociatedMatch(label: label, keys: keys, index: indexArg)
//                    } else {
//                        return nil
//                    }
//                }
//                var last = enumCases.removeLast()
//                last.associatedMatch = valueMatches
//                enumCases.append(last)
//            }
//        }
        // 带关联值的枚举要判断 Casematch 必须是 .string(....)
        
        
        return []
    }
}
