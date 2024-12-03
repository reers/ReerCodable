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

enum CaseStyle: String, CaseIterable {
    /// `flatcase`
    case flatCase
    
    /// `UPPERCASE`
    case upperCase
    
    /// `camelCase`
    case camelCase
    
    /// `PascalCase`
    case pascalCase
    
    /// `snake_case`
    case snakeCase
    
    /// `kebab-case`
    case kebabCase
    
    /// `camel_Snake_Case`
    case camelSnakeCase
    
    /// `Pascal_Snake_Case`
    case pascalSnakeCase
    
    /// `SCREAMING_SNAKE_CASE`
    case screamingSnakeCase
    
    /// `camel-Kebab-Case`
    case camelKebabCase
    
    /// `Pascal-Kebab-Case`
    case pascalKebabCase
    
    /// `SCREAMING-SNAKE-CASE`
    case screamingKebabCase
    
    
    var macroName: String {
        if rawValue.isEmpty { return rawValue }
        return rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

extension Array where Element == CaseStyle {
    func uniqueMerged(with other: [CaseStyle]) -> [CaseStyle] {
        var result: [CaseStyle] = []
        (self + other).forEach { style in
            if !result.contains(style) {
                result.append(style)
            }
        }
        return result
    }
}

protocol CaseStyleAttribute: PeerMacro {
    static var style: CaseStyle { get }
}

extension CaseStyleAttribute {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(VariableDeclSyntax.self)
        else {
            throw MacroError(text: "@\(style.macroName) macro is only for `struct`, `class` or a property.")
        }
        if let structDecl = declaration.as(StructDeclSyntax.self),
           structDecl.attributes.firstAttribute(named: "Codable") == nil {
            throw MacroError(text: "@\(style.macroName) macro can only be used with @Codable types.")
        }
        if let classDecl = declaration.as(ClassDeclSyntax.self),
           classDecl.attributes.firstAttribute(named: "Codable") == nil {
            throw MacroError(text: "@\(style.macroName) macro can only be used with @Codable types.")
        }
        return []
    }
}

public struct FlatCase: CaseStyleAttribute {
    static var style: CaseStyle { .flatCase }
}

public struct UpperCase: CaseStyleAttribute {
    static var style: CaseStyle { .upperCase }
}

public struct CamelCase: CaseStyleAttribute {
    static var style: CaseStyle { .camelCase }
}

public struct PascalCase: CaseStyleAttribute {
    static var style: CaseStyle { .pascalCase }
}

public struct SnakeCase: CaseStyleAttribute {
    static var style: CaseStyle { .snakeCase }
}

public struct KebabCase: CaseStyleAttribute {
    static var style: CaseStyle { .kebabCase }
}

public struct CamelSnakeCase: CaseStyleAttribute {
    static var style: CaseStyle { .camelSnakeCase }
}

public struct PascalSnakeCase: CaseStyleAttribute {
    static var style: CaseStyle { .pascalSnakeCase }
}

public struct ScreamingSnakeCase: CaseStyleAttribute {
    static var style: CaseStyle { .screamingSnakeCase }
}

public struct CamelKebabCase: CaseStyleAttribute {
    static var style: CaseStyle { .camelKebabCase }
}

public struct PascalKebabCase: CaseStyleAttribute {
    static var style: CaseStyle { .pascalKebabCase }
}

public struct ScreamingKebabCase: CaseStyleAttribute {
    static var style: CaseStyle { .screamingKebabCase }
}
