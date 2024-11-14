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


@attached(extension, conformances: Codable, CodableDelegate, names: arbitrary)
@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro Codable(memberwiseInit: Bool = true) = #externalMacro(module: "ReerCodableMacros", type: "Codable")

@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro CodableSubclass() = #externalMacro(module: "ReerCodableMacros", type: "CodableSubclass")

@attached(peer)
public macro CodingKey(_ key: String ...) = #externalMacro(module: "ReerCodableMacros", type: "CodingKey")

@attached(peer)
public macro EncodingKey(
    _ key: String,
    treatDotAsNested: Bool = true
) = #externalMacro(module: "ReerCodableMacros", type: "EncodingKey")

@attached(peer)
public macro IgnoreCoding() = #externalMacro(module: "ReerCodableMacros", type: "IgnoreCoding")

@attached(peer)
public macro Base64Coding() = #externalMacro(module: "ReerCodableMacros", type: "Base64Coding")

@attached(peer)
public macro DateCoding(_ strategy: DateCodingStrategy) = #externalMacro(module: "ReerCodableMacros", type: "DateCoding")

/// `flatcase`
@attached(peer)
public macro FlatCase() = #externalMacro(module: "ReerCodableMacros", type: "FlatCase")

/// `UPPERCASE`
@attached(peer)
public macro UpperCase() = #externalMacro(module: "ReerCodableMacros", type: "UpperCase")

/// `camelCase`
@attached(peer)
public macro CamelCase() = #externalMacro(module: "ReerCodableMacros", type: "CamelCase")

/// `PascalCase`
@attached(peer)
public macro PascalCase() = #externalMacro(module: "ReerCodableMacros", type: "PascalCase")

/// `snake_case`
@attached(peer)
public macro SnakeCase() = #externalMacro(module: "ReerCodableMacros", type: "SnakeCase")

/// `kebab-case`
@attached(peer)
public macro KebabCase() = #externalMacro(module: "ReerCodableMacros", type: "KebabCase")

/// `camel_Snake_Case`
@attached(peer)
public macro CamelSnakeCase() = #externalMacro(module: "ReerCodableMacros", type: "CamelSnakeCase")

/// `Pascal_Snake_Case`
@attached(peer)
public macro PascalSnakeCase() = #externalMacro(module: "ReerCodableMacros", type: "PascalSnakeCase")

/// `SCREAMING_SNAKE_CASE`
@attached(peer)
public macro ScreamingSnakeCase() = #externalMacro(module: "ReerCodableMacros", type: "ScreamingSnakeCase")

/// `camel-Kebab-Case`
@attached(peer)
public macro CamelKebabCase() = #externalMacro(module: "ReerCodableMacros", type: "CamelKebabCase")

/// `Pascal-Kebab-Case`
@attached(peer)
public macro PascalKebabCase() = #externalMacro(module: "ReerCodableMacros", type: "PascalKebabCase")

/// `SCREAMING-SNAKE-CASE`
@attached(peer)
public macro ScreamingKebabCase() = #externalMacro(module: "ReerCodableMacros", type: "ScreamingKebabCase")
