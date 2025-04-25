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
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // 1. 检查宏是否应用于类 (ClassDeclSyntax)
        // 2. 检查该类是否有继承子句 (inheritanceClause)，即它是一个子类
        guard let classDecl = declaration.as(ClassDeclSyntax.self), classDecl.inheritanceClause != nil else {
            // 如果不是子类，则抛出错误
            throw MacroError(text: "`@InheritedDecodable` must be used on a subclass.")
        }

        // 3. 创建 TypeInfo 实例以分析子类的结构
        //    你需要确保 TypeInfo 能正确处理继承关系
        let typeInfo = try TypeInfo(decl: classDecl)

        // 4. 生成需要 override 的 `init(from:)` 实现
        //    传递 isOverride: true 来确保生成的方法包含 `override` 关键字
        //    并且内部可能需要调用 super.init(from:)
        let decoderInit = try typeInfo.generateDecoderInit(isOverride: true)

        // 5. 返回仅包含 `init(from:)` override 实现的声明数组
        return [decoderInit]
    }
}
