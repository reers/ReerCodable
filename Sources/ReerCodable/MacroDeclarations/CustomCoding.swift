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

/// The `@CustomCoding` macro provides custom encoding and decoding logic for properties.
///
/// Using inline closure parameters:
/// ```swift
/// @CustomCoding<Int>(
///     decode: { decoder in
///         let temp: Int = try decoder.value(forKeys: "custom")
///         return temp * 1000  // Custom transformation during decoding
///     },
///     encode: { encoder, value in
///         try encoder.set(value, forKey: "custom")
///     }
/// )
/// var customValue: Int
/// ```
@attached(peer)
public macro CustomCoding<Value>(
    decode: ((_ decoder: any Decoder) throws -> Value)? = nil,
    encode: ((_ encoder: any Encoder, _ value: Value) throws -> Void)? = nil
) = #externalMacro(module: "ReerCodableMacros", type: "CustomCoding")

/// Protocol for defining custom coding logic in a separate type.
///
/// Implement this protocol to create reusable coding transformations
/// that can be applied to multiple properties using `@CustomCoding`.
public protocol CodingCustomizable {
    /// The type of value being encoded and decoded
    associatedtype Value: Codable
    
    /// Custom decoding implementation
    /// - Parameters:
    ///   - decoder: The decoder to read values from
    ///   - keys: property name and converted keys.
    /// - Returns: The decoded value after custom transformation
    static func decode(by decoder: any Decoder, keys: [String]) throws -> Value
    
    /// Custom encoding implementation
    /// - Parameters:
    ///   - encoder: The encoder to write values to
    ///   - key: property name.
    ///   - value: The value to encode
    static func encode(by encoder: any Encoder, key: String, value: Value) throws
}

/// The `@CustomCoding` macro with type-based customization.
///
/// Use this version when you have a type conforming to `CodingCustomizable`
/// that encapsulates your custom coding logic.
///
/// Example usage:
/// ```swift
/// struct IntTransformer: CodingCustomizable {
///     typealias Value = Int
///     
///     static func decode(by decoder: any Decoder, keys: [String]) throws -> Int {
///         let temp: Int = try decoder.value(forKeys: "custom")
///         return temp * 1000
///     }
///     
    ///     static func encode(by encoder: any Encoder, key: String, value: Value) throws {
///         try encoder.set(value, forKey: "custom_by")
///     }
/// }
///
/// @CustomCoding(IntTransformer.self)
/// var customValue: Int
/// ```
///
/// - Parameter customCodingType: A type conforming to `CodingCustomizable`
@attached(peer)
public macro CustomCoding(
    _ customCodingType: any CodingCustomizable.Type
) = #externalMacro(module: "ReerCodableMacros", type: "CustomCoding")
