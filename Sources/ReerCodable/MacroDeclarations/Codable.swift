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

// MARK: - Codable Macros

/// The `@Codable` macro provides automatic implementation of `Codable` protocol for Swift types.
///
/// Important Notes:
/// - In Xcode, only `@Codable` and `@InheritedCodable` macros can be expanded using "Expand Macro".
///   Other macros (like `@CodingKey`, `@DateCoding`, etc.) are markers for code generation and
///   won't show any expansion in Xcode.
/// - All types marked with `@Codable` automatically conform to `ReerCodableDelegate` protocol,
///   which provides hooks for custom coding logic:
///   ```swift
///   protocol ReerCodableDelegate {
///       // Called after decoding is complete
///       func didDecode(from decoder: any Decoder) throws
///       // Called before encoding begins
///       func willEncode(to encoder: any Encoder) throws
///   }
///   ```
///   Example usage:
///   ```swift
///   @Codable
///   struct User {
///       var name: String
///       var createdAt: Date
///       
///       func didDecode(from decoder: any Decoder) throws {
///           // Perform post-decode validation
///           guard !name.isEmpty else {
///               throw DecodingError.dataCorrupted(...)
///           }
///           // Or change model values by your custom logic
///           name = name.uppercased()
///       }
///       
///       func willEncode(to encoder: any Encoder) throws {
///           // Prepare data before encoding
///           if createdAt > Date() {
///               throw EncodingError.invalidValue(...)
///           }
///           // Or change model values by your custom logic
///           name = name.lowercased()
///       }
///   }
///   ```
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
/// - Add a static `default` instance if used `DefaultInstance`
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
@attached(extension, conformances: Codable, ReerCodableDelegate)
@attached(member, names: named(init), named(init(from:)), named(encode(to:)), named(default), named(copy))
public macro Codable(memberwiseInit: Bool = true) = #externalMacro(module: "ReerCodableMacros", type: "RECodable")

/// Decodable only
@attached(extension, conformances: Decodable, ReerCodableDelegate)
@attached(member, names: named(init(from:)), named(default), named(init), named(copy))
public macro Decodable(memberwiseInit: Bool = true) = #externalMacro(module: "ReerCodableMacros", type: "REDecodable")

/// Encodable only
@attached(extension, conformances: Encodable, ReerCodableDelegate)
@attached(member, names: named(encode(to:)), named(default), named(init), named(copy))
public macro Encodable(memberwiseInit: Bool = true) = #externalMacro(module: "ReerCodableMacros", type: "REEncodable")


// MARK: - Inheritance Macros

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
@attached(member, names: named(init(from:)), named(encode(to:)))
public macro InheritedCodable() = #externalMacro(module: "ReerCodableMacros", type: "InheritedCodable")

/// Inherited Decodable only
/// Generates the required `init(from:)` override for a subclass inheriting
/// from a `Decodable` (or `Codable`) base class.
/// It automatically calls `super.init(from:)` and decodes properties defined
/// within the subclass itself.
@attached(member, names: named(init(from:)))
public macro InheritedDecodable() = #externalMacro(module: "ReerCodableMacros", type: "InheritedDecodable")

// ⚠️⚠️⚠️ Note on the absence of a standalone `InheritedEncodable` macro:
//
// When a base class conforms to `Decodable` (often achieved using `@Codable`),
// its `init(from:)` initializer is typically marked `required`. This is crucial
// to ensure that any subclass can also fulfill the `Decodable` protocol requirements.
//
// Swift's inheritance rules mandate that any subclass *must* provide an implementation
// for all `required` initializers inherited from its superclass.
//
// A hypothetical `InheritedEncodable` macro would, by design, only generate the
// `override func encode(to:)` method. It would *not* provide the necessary
// `required init(from:)` implementation.
//
// Consequently, applying *only* `@InheritedEncodable` to a subclass inheriting
// from a `Codable` base class would inevitably lead to a compile-time error:
// "'required' initializer 'init(from:)' must be provided by subclass of 'BaseClass'".
//
// To satisfy the compiler, the subclass developer would *still* need to provide
// an `init(from:)` implementation, even if it just calls `super.init(from:)`.
// This required initializer can be conveniently generated by using either
// `@InheritedDecodable` or `@InheritedCodable`.
//
// Given that handling the `required init(from:)` is almost always necessary when
// inheriting from a `Codable` base class, a standalone `InheritedEncodable` macro
// offers very limited practical value and could easily cause confusion.
//
// Therefore, the recommended approach is:
// - Use `@InheritedDecodable` if you only need to customize decoding or simply
//   need the required `init(from:)` boilerplate (which calls super). You can
//   manually override `encode(to:)` if needed alongside this.
// - Use `@InheritedCodable` if you need to customize both decoding and encoding behavior
//   in the subclass.
