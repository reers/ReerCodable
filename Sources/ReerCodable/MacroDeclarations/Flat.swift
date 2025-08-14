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

/// The `@Flat` macro flattens a property during encoding and decoding.
///
/// When applied to a property:
/// - Decoding: The property's value is decoded from the same decoder as the enclosing type
///   (i.e., not from a nested key). This effectively treats the nested type's fields
///   as if they were at the same level as the enclosing type.
/// - Encoding: The property's value is encoded to the same encoder, merging its keys
///   into the top-level dictionary of the enclosing type.
///
/// Example:
/// ```swift
/// @Codable
/// struct User {
///     var name: String
///     var age: Int = 0
///
///     @Flat
///     var address: Address
/// }
///
/// @Codable
/// struct Address {
///     var country: String
///     var city: String
/// }
///
/// // Input:
/// // [
/// //   "name": "phoenix",
/// //   "age": 34,
/// //   "country": "China",
/// //   "city": "Beijing"
/// // ]
/// // Decoded: User(name: "phoenix", age: 34, address: Address(country: "China", city: "Beijing"))
/// ```
///
/// Constraints:
/// - Can only be applied to a stored property.
/// - Cannot be used together with any other macros on the same property; otherwise an error is thrown.
@attached(peer)
public macro Flat() = #externalMacro(module: "ReerCodableMacros", type: "Flat")


