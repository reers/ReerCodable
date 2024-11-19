//
//  CompactDecodingImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/18.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CompactDecoding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw MacroError(text: "@CompactDecoding macro is only for property.")
        }
        guard let type = variable.type else {
            return []
        }
        let trimmed = type.nonOptionalType.trimmingCharacters(in: .whitespaces)
        if (trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
           || trimmed.hasPrefix("Array<")
           || trimmed.hasPrefix("Dictionary<")
           || trimmed.hasPrefix("Set<") {
            return []
        }
        throw MacroError(text: "@CompactDecoding macro is only for Array, Dictionary and Set.")
    }
}
