//
//  Copyright 2024 reers.
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

/// The `@Codable` macro provides automatic implementation of `Codable` protocol for Swift types.
///
/// This macro can be applied to:
/// - `struct`
/// - `class`
/// - `enum`
///
/// The macro automatically generates:
/// - `init(from:)` decoder initializer
/// - `encode(to:)` encoder method
/// - Conformance to `Codable` protocol
/// - Conformance to `ReerCodableDelegate` protocol
/// - Additional helper members as needed
///
/// - Parameter memberwiseInit: If true (default), generates a memberwise initializer for the type
///
/// Example usage:
/// ```swift
/// @Codable
/// struct Person {
///     let name: String
///     let age: Int
/// }
/// ```
@attached(extension, conformances: Codable, ReerCodableDelegate, names: arbitrary)
@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro Codable(memberwiseInit: Bool = true) = #externalMacro(module: "ReerCodableMacros", type: "Codable")

/// The `@InheritedCodable` macro provides automatic implementation of `Codable` protocol for classes
/// that inherit from a `Codable` conforming superclass.
///
/// This macro specifically handles:
/// - Proper encoding of inherited properties
/// - Proper decoding of inherited properties
/// - Automatic implementation of required `Codable` methods
///
/// Example usage:
/// ```swift
/// class Parent: Codable {
///     let parentProperty: String
/// }
///
/// @InheritedCodable
/// class Child: Parent {
///     let childProperty: Int
/// }
/// ```
@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro InheritedCodable() = #externalMacro(module: "ReerCodableMacros", type: "InheritedCodable")
