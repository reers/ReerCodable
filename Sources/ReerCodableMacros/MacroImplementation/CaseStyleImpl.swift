//
//  CaseStyleImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/13.
//

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
            declaration.as(StructDeclSyntax.self) != nil
            || declaration.as(ClassDeclSyntax.self) !=  nil
            || declaration.as(VariableDeclSyntax.self) !=  nil
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
