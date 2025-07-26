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

/// Extension to `Decoder` providing convenient methods for decoding values using alternative keys.
///
/// This extension adds functionality to decode values by trying multiple possible keys,
/// which is particularly useful when the same value might appear under different key names
/// in the JSON, such as when handling data from different API versions.
///
/// Example 1: Basic Usage with Alternative Keys
/// ```swift
/// // Given JSON might be either:
/// { "user_id": 123 }
/// // or
/// { "userId": 123 }
/// // or
/// { "id": 123 }
///
/// // You can decode using multiple possible keys:
/// let id: Int = try decoder.value(forKeys: "user_id", "userId", "id")
/// ```
///
/// Example 2: Usage with `@CustomCoding`
/// ```swift
/// struct User {
///     @CustomCoding<Int>(
///         decode: { decoder in
///             // Try multiple possible keys for backward compatibility
///             let value: Int = try decoder.value(forKeys: "count", "total_count", "size")
///             return value * 1000
///         },
///         encode: { encoder, value in
///             try encoder.set(value, forKey: "count")
///         }
///     )
///     var count: Int
/// }
/// ```
///
/// This is more convenient than trying multiple keys manually:
/// ```swift
/// // Without extension:
/// let container = try decoder.container(keyedBy: AnyCodingKey.self)
/// let count = try? container.decode(Int.self, forKey: "count")
///     ?? container.decode(Int.self, forKey: "total_count")
///     ?? container.decode(Int.self, forKey: "size")
///
/// // With extension:
/// let count: Int = try decoder.value(forKeys: "count", "total_count", "size")
/// ```
public extension Decoder {
    func value<Value: Decodable>(forKeys keys: String...) throws -> Value {
        let container = try container(keyedBy: AnyCodingKey.self)
        return try container.decode(type: Value.self, keys: keys.map { .init($0, $0.contains(".")) })
    }
    
    func value<Value: Decodable>(forKeys keys: [String]) throws -> Value {
        let container = try container(keyedBy: AnyCodingKey.self)
        return try container.decode(type: Value.self, keys: keys.map { .init($0, $0.contains(".")) })
    }
}
