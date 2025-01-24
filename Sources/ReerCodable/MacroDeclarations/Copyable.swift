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

/// A macro that automatically generates copying functionality for types.
///
/// The `@Copyable` macro generates two types of copy methods depending on the type:
///
/// 1. For classes and structs:
/// - Generates a `copy()` method with optional parameters for all properties
/// - Allows partial property updates during copying
/// - For classes, creates a new instance with different memory address
///
/// 2. For enums
/// - Generates a simple `copy()` method that returns self
///
/// # Examples:
///
/// ## Struct Example:
/// ```swift
/// @Codable
/// @Copyable
/// struct Model {
///     var name: String
///     let id: Int
///     var desc: String?
/// }
///
/// // Generated methods:
/// // func copy(name: String? = nil, id: Int? = nil, desc: String? = nil) -> Model
///
/// let model = Model(name: "phoenix", id: 123, desc: "Swift Developer")
/// let copy1 = model.copy()  // Full copy
/// let copy2 = model.copy(name: "new name")  // Partial update
/// ```
///
/// ## Generic Class Example:
/// ```swift
/// @Codable
/// @Copyable
/// class Model<Element: Codable> {
///     var name: String
///     var data: Element?
/// }
///
/// // Generated methods maintain generic constraints
/// // Creates new instance with different memory address
/// ```
///
/// ## Enum Example:
/// ```swift
/// @Codable
/// @Copyable
/// enum Season {
///     case spring, summer, fall, winter
/// }
///
/// // Generates simple copy method returning self
/// ```
///
/// # Features:
/// - Supports both mutable and immutable properties
/// - Handles optional and non-optional types
/// - Preserves generic type constraints
/// - Creates true copies for reference types (different memory addresses)
/// - Supports partial property updates
///
/// # Requirements:
/// - Must be used with `@Codable` macro
/// - Properties must be copyable
/// - For generic types, type parameters must conform to Codable
///
/// # Usage Notes:
/// - For structs and classes, generated copy methods allow updating specific properties
/// - For classes, each copy creates a new instance (different memory address)
/// - For enums, simply returns self
/// - All properties are optional parameters in copy method
///
@attached(peer)
public macro Copyable() = #externalMacro(module: "ReerCodableMacros", type: "Copyable")
