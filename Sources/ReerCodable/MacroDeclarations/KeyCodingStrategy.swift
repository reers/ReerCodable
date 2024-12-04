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

/// Key Coding Strategy Macros
///
/// These macros provide various naming convention transformations for coding keys.
/// They can be applied at both the type level (struct/class) and property level,
/// and can be combined with `@CodingKey` for more flexible key customization.
/// When used together with `@CodingKey`, the `@CodingKey` takes precedence.
///
/// 1. Type-level usage (affects all properties):
/// ```swift
/// @Codable
/// @SnakeCase  // All properties will use snake_case unless overridden
/// struct User {
///     var firstName: String   // Encoded as "first_name", but can be decoded from "first_name"
///     
///     @CodingKey("CUSTOM_ID")  // Takes precedence over @SnakeCase
///     var userID: String     // Encoded as "CUSTOM_ID"
/// }
/// ```
///
/// 2. Property-level usage (affects single property):
/// ```swift
/// @Codable
/// struct User {
///     @SnakeCase
///     @CodingKey("user_first_name", "firstName")  // CodingKey takes precedence
///     var firstName: String   // Encoded as "user_first_name", and can be decoded from "first_name"
///     
///     @ScreamingSnakeCase
///     var userID: String     // This property uses SCREAMING_SNAKE_CASE: "USER_ID"
/// }
/// ```
///
/// Available transformations:
/// - `@FlatCase`: `flatcase`
/// - `@UpperCase`: `UPPERCASE`
/// - `@CamelCase`: `camelCase`
/// - `@PascalCase`: `PascalCase`
/// - `@SnakeCase`: `snake_case`
/// - `@KebabCase`: `kebab-case`
/// - `@CamelSnakeCase`: `camel_Snake_Case`
/// - `@PascalSnakeCase`: `Pascal_Snake_Case`
/// - `@ScreamingSnakeCase`: `SCREAMING_SNAKE_CASE`
/// - `@CamelKebabCase`: `camel-Kebab-Case`
/// - `@PascalKebabCase`: `Pascal-Kebab-Case`
/// - `@ScreamingKebabCase`: `SCREAMING-KEBAB-CASE`

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

/// `SCREAMING-KEBAB-CASE`
@attached(peer)
public macro ScreamingKebabCase() = #externalMacro(module: "ReerCodableMacros", type: "ScreamingKebabCase")
