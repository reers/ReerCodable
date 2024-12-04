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

/// The `@CodingKey` macro customizes the key used for encoding and decoding a property.
///
/// This macro allows you to specify one or more alternative keys for a property:
/// - The first key is used for encoding
/// - All keys are tried in order during decoding (useful for backward compatibility)
///
/// Example usage:
/// ```swift
/// @Codable
/// struct User {
///     @CodingKey("user_id", "id")  // Will encode as "user_id", but can decode from both "user_id" or "id"
///     let userId: String
///     
///     @CodingKey("full_name")
///     let name: String
/// }
/// ```
@attached(peer)
public macro CodingKey(_ key: String...) = #externalMacro(module: "ReerCodableMacros", type: "CodingKey")

/// The `@EncodingKey` macro customizes the key used only for encoding a property.
///
/// This macro provides more control over the encoding process:
/// - Specifies a custom key name for encoding
/// - Can treat dot notation as nested keys when `treatDotAsNested` is true
/// - When used together with `@CodingKey`, this macro takes precedence during encoding,
///   while `@CodingKey` is still used for decoding
///
/// Example usage:
/// ```swift
/// @Codable
/// struct User {
///     @CodingKey("user_id", "id")      // Used for decoding from both keys
///     @EncodingKey("user.identifier")   // Takes precedence for encoding. Will be encoded as nested: { "user": { "identifier": "value" } }
///     let userId: String
///     
///     @EncodingKey("data.name", treatDotAsNested: false)  // Will be encoded flat: { "data.name": "value" }
///     let name: String
/// }
/// ```
///
/// - Parameters:
///   - key: The key to use for encoding
///   - treatDotAsNested: If true (default), dots in the key will create nested structures
@attached(peer)
public macro EncodingKey(
    _ key: String,
    treatDotAsNested: Bool = true
) = #externalMacro(module: "ReerCodableMacros", type: "EncodingKey")