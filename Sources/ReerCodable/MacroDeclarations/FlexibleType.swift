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

/// A macro that enables flexible type conversion during decoding.
///
/// When applied to a property or type, this macro allows for automatic type conversion between basic types
/// during the decoding process. It supports conversions between:
/// - Numbers (Int, Double, Float, etc.)
/// - Strings and Numbers
/// - Booleans and Numbers (0/1)
/// - Booleans and Strings ("true"/"false", "yes"/"no")
///
/// Example usage:
/// ```swift
/// struct User: Codable {
///     @FlexibleType
///     var age: Int // Can decode from String "25" or Double 25.0
///
///     @FlexibleType
///     var isActive: Bool // Can decode from Int 1/0 or String "true"/"false"
/// }
///
/// @FlexibleType
/// struct Settings: Codable {
///     // All properties in this type will support flexible type conversion
///     var count: Int
///     var enabled: Bool
///     var name: String
/// }
/// ```
///
/// The supported type conversions are defined in the `TypeConvertible` protocol implementations.
@attached(peer)
public macro FlexibleType() = #externalMacro(module: "ReerCodableMacros", type: "FlexibleType")
