//
//  Copyright © 2020 winddpan.
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
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RECodable {}

extension RECodable: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else {
            throw MacroError(text: "@Codable macro is only for `struct`, `class` or `enum`.")
        }
        
        var codableExisted = false
        if let inheritedType = declaration.inheritanceClause?.inheritedTypes,
           inheritedType.contains(where: { $0.type.trimmedDescription == "Codable" }) {
            codableExisted = true
        }
        let extensionDecl: DeclSyntax =
            """
            extension \(type.trimmed):\(raw: codableExisted ? "" : "Codable,") ReerCodableDelegate {}
            """
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
}

extension RECodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let members = declaration.memberBlock.members
        
        for member in members {
            if let initDecl = member.decl.as(InitializerDeclSyntax.self),
               initDecl.signature.parameterClause.parameters.count == 1,
               initDecl.signature.parameterClause.parameters.first?.firstName.text == "from",
               initDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Decoder" {
                throw MacroError(text: "Please use the `@Codable` macro-generated implementation instead of manually implementing `init(from:)`.")
            }
            
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               funcDecl.name.text == "encode" &&
               funcDecl.signature.parameterClause.parameters.count == 1 &&
               funcDecl.signature.parameterClause.parameters.first?.firstName.text == "to" &&
               funcDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Encoder" {
                throw MacroError(text: "Please use the `@Codable` macro-generated implementation instead of manually implementing `encode(to:)`.")
            }
        }
        
        let typeInfo = try TypeInfo(decl: declaration)
        let decoder = try typeInfo.generateDecoderInit()
        let encoder = try typeInfo.generateEncoderFunc()
        
        var hasMemberwiseInit = true
        if case .argumentList(let list) = node.arguments,
           let item = list.first(where: { $0.label?.text == "memberwiseInit" }),
           item.expression.description == "false" {
            hasMemberwiseInit = false
        }
        
        var hasDefaultInstance = false
        if declaration.attributes.containsAttribute(named: "DefaultInstance") {
            hasDefaultInstance = true
        }
        
        if hasDefaultInstance && !hasMemberwiseInit {
            throw MacroError(text: "@DefaultInstance requires 'memberwiseInit' is 'true'")
        }
        
        var hasCopyable = false
        if declaration.attributes.containsAttribute(named: "Copyable") {
            hasCopyable = true
        }
        
        if hasCopyable && !hasMemberwiseInit {
            throw MacroError(text: "@Copyable requires 'memberwiseInit' is 'true'")
        }
        
        var decls = [decoder, encoder]
        if hasMemberwiseInit, !declaration.is(EnumDeclSyntax.self) {
            decls.append(try typeInfo.generateMemberwiseInit())
        }
        if hasDefaultInstance {
            decls.append(try typeInfo.generateDefaultInstance())
        }
        if hasCopyable {
            decls.append(try typeInfo.generateCopy())
        }
        return decls
    }
}

// MARK: - Decodable only

public struct REDecodable {}

extension REDecodable: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else {
            throw MacroError(text: "@Decodable macro is only for `struct`, `class` or `enum`.")
        }

        var decodableExisted = false
        if let inheritedTypeClause = declaration.inheritanceClause {
            decodableExisted = inheritedTypeClause.inheritedTypes.contains { inheritedType in
                let typeName = inheritedType.type.trimmedDescription
                return typeName == "Decodable" || typeName == "Codable"
            }
        }

        let extensionDecl: DeclSyntax =
            """
            extension \(type.trimmed): \(raw: decodableExisted ? "" : "Decodable, ")ReerCodableDelegate {}
            """
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
}

extension REDecodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let members = declaration.memberBlock.members

        for member in members {
            if let initDecl = member.decl.as(InitializerDeclSyntax.self),
               initDecl.signature.parameterClause.parameters.count == 1,
               initDecl.signature.parameterClause.parameters.first?.firstName.text == "from",
               initDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Decoder" {
                throw MacroError(text: "Please use the `@Decodable` macro-generated implementation instead of manually implementing `init(from:)`.")
            }
        }

        let typeInfo = try TypeInfo(decl: declaration)
        let decoder = try typeInfo.generateDecoderInit()
        
        var hasMemberwiseInit = true
        if case .argumentList(let list) = node.arguments {
            if let item = list.first(where: { $0.label?.text == "memberwiseInit" }),
               item.expression.description == "false" {
                hasMemberwiseInit = false
            }
        }

        var hasDefaultInstance = false
        if declaration.attributes.containsAttribute(named: "DefaultInstance") {
            hasDefaultInstance = true
        }

        if hasDefaultInstance && !hasMemberwiseInit {
            throw MacroError(text: "@DefaultInstance requires 'memberwiseInit' is 'true'")
        }

        var hasCopyable = false
        if declaration.attributes.containsAttribute(named: "Copyable") {
            hasCopyable = true
        }

        if hasCopyable && !hasMemberwiseInit {
            throw MacroError(text: "@Copyable requires 'memberwiseInit' is 'true'")
        }

        var decls = [decoder]

        if hasMemberwiseInit, !declaration.is(EnumDeclSyntax.self) {
            decls.append(try typeInfo.generateMemberwiseInit())
        }
        if hasDefaultInstance {
            decls.append(try typeInfo.generateDefaultInstance())
        }
        if hasCopyable {
            decls.append(try typeInfo.generateCopy())
        }

        return decls
    }
}

// MARK: - Encodable only

public struct REEncodable {}

extension REEncodable: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard
            declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
        else {
            throw MacroError(text: "@Encodable macro is only for `struct`, `class` or `enum`.")
        }

        var encodableExisted = false
        if let inheritedTypeClause = declaration.inheritanceClause {
            encodableExisted = inheritedTypeClause.inheritedTypes.contains { inheritedType in
                let typeName = inheritedType.type.trimmedDescription
                return typeName == "Encodable" || typeName == "Codable"
            }
        }

        let extensionDecl: DeclSyntax =
            """
            extension \(type.trimmed): \(raw: encodableExisted ? "" : "Encodable, ")ReerCodableDelegate {}
            """
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
}

extension REEncodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let members = declaration.memberBlock.members

        for member in members {
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               funcDecl.name.text == "encode",
               funcDecl.signature.parameterClause.parameters.count == 1,
               funcDecl.signature.parameterClause.parameters.first?.firstName.text == "to",
               funcDecl.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self)?.constraint.as(IdentifierTypeSyntax.self)?.name.text == "Encoder" {
                throw MacroError(text: "Please use the `@Encodable` macro-generated implementation instead of manually implementing `encode(to:)`.")
            }
        }

        let typeInfo = try TypeInfo(decl: declaration)
        let encoderFunc = try typeInfo.generateEncoderFunc()

        var hasMemberwiseInit = true
        if case .argumentList(let list) = node.arguments {
            if let item = list.first(where: { $0.label?.text == "memberwiseInit" }),
               item.expression.description == "false" {
                hasMemberwiseInit = false
            }
        }

        var hasDefaultInstance = false
        if declaration.attributes.containsAttribute(named: "DefaultInstance") {
            hasDefaultInstance = true
        }

        if hasDefaultInstance && !hasMemberwiseInit {
            throw MacroError(text: "@DefaultInstance requires 'memberwiseInit' is 'true' (when used with @Encodable)")
        }

        var hasCopyable = false
        if declaration.attributes.containsAttribute(named: "Copyable") {
            hasCopyable = true
        }

        if hasCopyable && !hasMemberwiseInit {
             throw MacroError(text: "@Copyable requires 'memberwiseInit' is 'true' (when used with @Encodable)")
        }

        var decls = [encoderFunc]

        if hasMemberwiseInit, !declaration.is(EnumDeclSyntax.self) {
            decls.append(try typeInfo.generateMemberwiseInit())
        }
        if hasDefaultInstance {
            decls.append(try typeInfo.generateDefaultInstance())
        }
        if hasCopyable {
            decls.append(try typeInfo.generateCopy())
        }

        return decls
    }
}
