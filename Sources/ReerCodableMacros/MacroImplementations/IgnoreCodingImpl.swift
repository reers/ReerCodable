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

private enum IgnoreCodingMode: Equatable {
    case both
    case encoding
    case decoding

    var macroName: String {
        switch self {
        case .both:
            return "CodingIgnored"
        case .encoding:
            return "EncodingIgnored"
        case .decoding:
            return "DecodingIgnored"
        }
    }

    var diagnosticPrefix: String {
        "@\(macroName) macro"
    }
}

private func validateIgnoredProperty(
    declaration: some DeclSyntaxProtocol,
    mode: IgnoreCodingMode
) throws {
    guard
        let variable = declaration.as(VariableDeclSyntax.self),
        let name = variable.name
    else {
        throw MacroError(text: "\(mode.diagnosticPrefix) is only for property.")
    }

    let ignoreMacros = ["CodingIgnored", "EncodingIgnored", "DecodingIgnored"]
    let usedIgnoreMacros = ignoreMacros.filter { variable.attributes.containsAttribute(named: $0) }
    if usedIgnoreMacros.count > 1 {
        throw MacroError(
            text: "\(mode.diagnosticPrefix) cannot be used together with @\(usedIgnoreMacros.filter { $0 != mode.macroName }.joined(separator: ", @"))."
        )
    }

    if mode == .encoding, variable.attributes.containsAttribute(named: "EncodingKey") {
        throw MacroError(text: "@EncodingIgnored macro cannot be used together with @EncodingKey.")
    }

    if mode != .encoding {
        if variable.isOptional {
            return
        }
        if variable.initExpr != nil {
            return
        }
        if let type = variable.type,
           canGenerateDefaultValue(for: type) {
            return
        }
        throw MacroError(text: "The ignored property `\(name)` should have a default value, or be set as an optional type.")
    }
}

public struct CodingIgnored: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try validateIgnoredProperty(declaration: declaration, mode: .both)
        return []
    }
}

public struct EncodingIgnored: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try validateIgnoredProperty(declaration: declaration, mode: .encoding)
        return []
    }
}

public struct DecodingIgnored: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try validateIgnoredProperty(declaration: declaration, mode: .decoding)
        return []
    }
}

func canGenerateDefaultValue(for type: String) -> Bool {
    let trimmed = type.trimmingCharacters(in: .whitespaces)
    let basicType = [
        "Int", "Int8", "Int16", "Int32", "Int64", "Int128",
        "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "UInt128",
        "Bool", "String", "Float", "Double"
    ].contains(trimmed)
    if basicType
       || (trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
       || trimmed.hasPrefix("Set<") {
        return true
    }
    return false
}
