//
//  Copyright © 2024 reers.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
               functionCall.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.trimmedDescription == "pathValue",
               let param = functionCall.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.trimmedDescription,
               !param.contains("."){
                throw MacroError(text: ".pathValue(\(param)) requires its param contains at least one dot `.`")
            }
        }
        
        return []
    }
}
