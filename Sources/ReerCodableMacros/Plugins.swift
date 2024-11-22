//
//  File.swift
//  
//
//  Created by phoenix on 2024/10/16.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ReerCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
        CodableSubclass.self,
        CodingKey.self,
        EncodingKey.self,
        IgnoreCoding.self,
        Base64Coding.self,
        DateCoding.self,
        CompactDecoding.self,
        CustomCoding.self,
        CodingCase.self,
        FlatCase.self,
        UpperCase.self,
        CamelCase.self,
        SnakeCase.self,
        PascalCase.self,
        KebabCase.self,
        CamelSnakeCase.self,
        PascalSnakeCase.self,
        ScreamingSnakeCase.self,
        CamelKebabCase.self,
        PascalKebabCase.self,
        ScreamingKebabCase.self,
    ]
}
