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

/// Provides a fallback value when decoding fails or keys are missing.
///
/// ```swift
/// @Decodable
/// struct Flags {
///     @DecodingDefault(false)
///     let isEnabled: Bool
/// }
/// ```
/// The decoded value uses the provided expression when decoding throws or when
/// the key is not present.
@attached(peer)
public macro DecodingDefault<Value>(
    _ value: Value
) = #externalMacro(module: "ReerCodableMacros", type: "DecodingDefault")

/// Provides a fallback value when encoding optional properties.
///
/// When applied to an optional property, the expression is encoded in place of
/// `nil`, ensuring downstream encoders always see a concrete value.
@attached(peer)
public macro EncodingDefault<Value>(
    _ value: Value
) = #externalMacro(module: "ReerCodableMacros", type: "EncodingDefault")

/// Provides a fallback value for both encoding and decoding.
///
/// This macro combines the behavior of `@DecodingDefault` and `@EncodingDefault`
/// for cases where both directions should share the same default.
@attached(peer)
public macro CodingDefault<Value>(
    _ value: Value
) = #externalMacro(module: "ReerCodableMacros", type: "CodingDefault")
