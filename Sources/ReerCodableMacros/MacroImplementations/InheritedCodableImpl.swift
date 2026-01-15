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
import SwiftSyntaxMacros

public struct InheritedCodable: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self), declaration.inheritanceClause != nil else {
            throw MacroError(text: "`@InheritedCodable` must be used on a subclass.")
        }
        let typeInfo = try TypeInfo(decl: declaration)
        let decoder = try typeInfo.generateDecoderInit(isOverride: true)
        let encoder = try typeInfo.generateEncoderFunc(isOverride: true)
        return [decoder, encoder]
    }
}

// MARK: - Inherited Decodable only

public struct InheritedDecodable: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // 1. Check if the macro is applied to a class (ClassDeclSyntax)
        // 2. Check if the class has an inheritance clause (inheritanceClause), i.e., it is a subclass
        guard let classDecl = declaration.as(ClassDeclSyntax.self), classDecl.inheritanceClause != nil else {
            // If it's not a subclass, throw an error
            throw MacroError(text: "`@InheritedDecodable` must be used on a subclass.")
        }

        // 3. Create a TypeInfo instance to analyze the subclass structure
        //    You need to ensure TypeInfo can properly handle inheritance relationships
        let typeInfo = try TypeInfo(decl: classDecl)

        // 4. Generate the `init(from:)` implementation that needs to override
        //    Pass isOverride: true to ensure the generated method includes the `override` keyword
        //    and internally may need to call super.init(from:)
        let decoderInit = try typeInfo.generateDecoderInit(isOverride: true)

        // 5. Return an array of declarations containing only the `init(from:)` override implementation
        return [decoderInit]
    }
}
