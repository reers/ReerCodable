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

/// Matchers for enum case decoding.
///
/// Note: `.nested` cannot be used together with other matchers (`.string`, `.int`, etc.).
/// For enums with associated values, only `.nested` or `.string` can be used.
public enum CaseMatcher {
    /// Match a boolean value
    case bool(Bool)
    /// Match an integer value
    case int(Int)
    /// Match a double value
    case double(Double)
    /// Match a string value
    case string(String)
    /// Match a nested path using dot notation (e.g., "type.middle.youtube")
    case nested(String)
}

/// Configuration for associated values in enum cases.
///
/// Used to specify how associated values should be decoded from JSON.
/// Can be initialized with either a label-based or index-based configuration.
public struct CaseValue {
    let label: String?
    let keys: [String]
    let index: Int?
    
    /// Create a label-based case value configuration.
    /// - Parameters:
    ///   - label: The associated value's label in the enum case
    ///   - keys: The JSON keys to try for decoding this value
    public init(label: String, keys: String...) {
        self.label = label
        self.keys = keys
        self.index = nil
    }
    
    /// Create an index-based case value configuration.
    /// - Parameters:
    ///   - index: The position of the associated value in the enum case
    ///   - keys: The JSON keys to try for decoding this value
    public init(index: Int, keys: String...) {
        self.keys = keys
        self.index = index
        self.label = nil
    }
}

/// The `@CodingCase` macro provides custom encoding and decoding for enum cases.
///
/// This macro supports two main use cases:
/// 1. Simple enum cases without associated values
/// 2. Complex enum cases with associated values
///
/// Important restrictions:
/// - `.nested` matcher cannot be combined with other matchers
/// - For enums with any associated values, only `.nested` or `.string` matchers can be used
///
/// Example 1: Simple enum without associated values:
/// ```swift
/// @Codable
/// enum Phone {
///     @CodingCase(match: .bool(true), .int(8), .string("apple"))
///     case apple
///     
///     @CodingCase(match: .string("MI"), .string("xiaomi"))
///     case mi
/// }
/// ```
///
/// Example 2: Enum with associated values using nested matching:
/// ```
/// {
///     "type": {
///         "middle": "youtube"
///     }
/// },
/// {
///     "type": "vimeo",
///     "ID": "234961067",
///     "minutes": 999999
/// }
/// ```
///
/// ```swift
/// @Codable
/// enum Video {
///     @CodingCase(match: .nested("type.middle.youtube"))
///     case youTube
///     
///     @CodingCase(
///         match: .nested("type.vimeo"),
///         values: [
///             CaseValue(label: "id", keys: "ID", "Id"),
///             .init(index: 2, keys: "minutes")
///         ]
///     )
///     case vimeo(id: String, duration: TimeInterval = 33, Int)
/// }
/// ```
///
/// Example 3: Enum with associated values using string matching:
/// ```
/// {
///     "youtube": {
///         "id": "ujOc3a7Hav0",
///         "_1": 44.5
///     }
/// },
/// {
///     "vimeo": {
///         "ID": "234961067",
///         "minutes": 999999
///     }
/// }
/// ```
///
/// ```swift
/// @Codable
/// enum Video {
///     @CodingCase(match: .string("youtube"))
///     case youTube
///     
///     @CodingCase(
///         match: .string("vimeo"),
///         values: [
///             CaseValue(label: "id", keys: "ID"),
///             .init(label: "duration", keys: "minutes")
///         ]
///     )
///     case vimeo(id: String, duration: TimeInterval)
/// }
/// ```
///
/// - Parameters:
///   - cases: One or more matchers to identify the enum case
///   - values: Configuration for decoding associated values, if any
@attached(peer)
public macro CodingCase(
    match cases: CaseMatcher...,
    values: [CaseValue] = []
) = #externalMacro(module: "ReerCodableMacros", type: "CodingCase")
