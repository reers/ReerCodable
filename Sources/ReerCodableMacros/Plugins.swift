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
        CodingKey.self
    ]
}
