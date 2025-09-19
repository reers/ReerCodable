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
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Copyable: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else {
            throw MacroError(text: "@Copyable macro is only for `struct`, `class` and `enum`.")
        }
        if let structDecl = declaration.as(StructDeclSyntax.self),
           !structDecl.attributes.containsAttribute(named: "Codable")
           && !structDecl.attributes.containsAttribute(named: "Decodable")
           && !structDecl.attributes.containsAttribute(named: "Encodable") {
            throw MacroError(text: "@Copyable macro can only be used with @Decodable, @Encodable or @Codable types.")
        }
        if let classDecl = declaration.as(ClassDeclSyntax.self),
           !classDecl.attributes.containsAttribute(named: "Codable")
           && !classDecl.attributes.containsAttribute(named: "Decodable")
           && !classDecl.attributes.containsAttribute(named: "Encodable") {
            throw MacroError(text: "@Copyable macro can only be used with @Decodable, @Encodable or @Codable types.")
        }
        if let enumDecl = declaration.as(EnumDeclSyntax.self),
           !enumDecl.attributes.containsAttribute(named: "Codable")
           && !enumDecl.attributes.containsAttribute(named: "Decodable")
           && !enumDecl.attributes.containsAttribute(named: "Encodable") {
            throw MacroError(text: "@Copyable macro can only be used with @Decodable, @Encodable or @Codable types.")
        }
        return []
    }
}
