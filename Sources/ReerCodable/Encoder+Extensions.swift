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

/// Extension to `Encoder` providing convenient methods for encoding values with specific keys.
///
/// This extension simplifies the process of encoding values, particularly when used with
/// `@CustomCoding` or when you need to handle nested keys using dot notation.
///
/// Example 1: Basic Usage
/// ```swift
/// // Encode a value with a simple key
/// try encoder.set(100, forKey: "count")
/// // Results in: { "count": 100 }
///
/// // Encode a value with a nested key using dot notation
/// try encoder.set("John", forKey: "user.name")
/// // Results in: { "user": { "name": "John" } }
///
/// // Encode without treating dots as nested keys
/// try encoder.set("John", forKey: "user.name", treatDotAsNested: false)
/// // Results in: { "user.name": "John" }
/// ```
///
/// Example 2: Usage with `@CustomCoding`
/// ```swift
/// struct User {
///     @CustomCoding<Int>(
///         decode: { decoder in
///             let value: Int = try decoder.value(forKeys: "count", "total")
///             return value * 1000
///         },
///         encode: { encoder, value in
///             // Encode the value under a specific key
///             try encoder.set(value, forKey: "count")
///             // Or encode it as a nested value
///             try encoder.set(value / 1000, forKey: "stats.raw_count")
///         }
///     )
///     var count: Int
/// }
/// ```
public extension Encoder {
    /// Encodes a value with a specific key, optionally treating dots in the key as nested path.
    ///
    /// - Parameters:
    ///   - value: The value to encode
    ///   - key: The key to encode the value under
    ///   - treatDotAsNested: If true (default), treats dots in the key as nested path separators.
    ///                       If false, uses the key as-is.
    /// - Throws: `EncodingError` if the value cannot be encoded or if the key path is invalid.
    func set<Value: Encodable>(_ value: Value, forKey key: String, treatDotAsNested: Bool = true) throws {
        var container = container(keyedBy: AnyCodingKey.self)
        try container.encode(value: value, key: key, treatDotAsNested: treatDotAsNested)
    }
}
