//
//  Base64CodingImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/13.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct Base64Coding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let name = variable.name
        else {
            throw MacroError(text: "@Base64Coding macro is only for property.")
        }
        
        if variable.attributes.firstAttribute(named: "Base64Coding") != nil {
            guard let type = variable.type else {
                return []
            }
            if ["Data", "Data?", "[UInt8]", "[UInt8]?"].contains(type) {
                return []
            }
            throw MacroError(text: "@Base64Coding macro is only for `Data` or `[UInt8]`.")
        }
        return []
    }
}
