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
            throw MacroError(text: "@EncodingKey macro is only for property.")
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
