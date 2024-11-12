//
//  IgnoreCodingImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/12.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct IgnoreCoding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let name = variable.name
        else {
            return []
        }
        
        if variable.firstAttribute(named: "IgnoreCoding") != nil {
            if variable.isOptional {
                return []
            }
            if variable.initExpr != nil {
                return []
            }
            if let type = variable.type,
               canGenerateDefaultValue(for: type) {
                return []
            }
            throw MacroError(text: "The ignored property `\(name)` should have a default value, or be set as an optional type.")
        }
        return []
    }
    
    static func canGenerateDefaultValue(for type: String) -> Bool {
        let trimmed = type.trimmingCharacters(in: .whitespaces)
        let basicType = [
            "Int", "Int8", "Int16", "Int32", "Int64",
            "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Bool", "String", "Float", "Double"
        ].contains(trimmed)
        if basicType
           || (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            return true
        }
        return false
    }
}
