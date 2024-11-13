//
//  SnakeCaseImpl.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/13.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct SnakeCase: PeerMacro {
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
            // TODO: - also used for variable
            throw MacroError(text: "@SnakeCase macro is only for `struct`, `class` or a property.")
        }
//        guard
//            let variable = declaration.as(VariableDeclSyntax.self),
//            let name = variable.name
//        else {
//            return []
//        }
//        
//        if variable.firstAttribute(named: "SnakeCase") != nil {
//            if variable.isOptional {
//                return []
//            }
//            if variable.initExpr != nil {
//                return []
//            }
//            if let type = variable.type,
//               canGenerateDefaultValue(for: type) {
//                return []
//            }
//            throw MacroError(text: "The ignored property `\(name)` should have a default value, or be set as an optional type.")
//        }
        return []
    }
}
