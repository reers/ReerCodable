//
//  CodingKeyImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/8.
//


import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingKey: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
