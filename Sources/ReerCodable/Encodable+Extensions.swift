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

import Foundation

/// Extension to `Encodable` providing convenient encoding methods for different output formats.
///
/// This extension provides methods to easily encode objects to:
/// - Data
/// - String (JSON)
/// - Dictionary ([String: Any])
/// - Array ([Any])
///
/// Example usage:
/// ```swift
/// @Codable
/// struct User {
///     let name: String
///     let age: Int
/// }
///
/// let user = User(name: "John", age: 30)
///
/// // 1. Encode to Data
/// let data = try user.encodedData()
///
/// // 2. Encode to JSON String
/// let jsonString = try user.encodedString()
/// // Result: {"name":"John","age":30}
///
/// // 3. Encode to Dictionary
/// let dict = try user.encodedDict()
/// // Result: ["name": "John", "age": 30]
///
/// // 4. Custom JSONEncoder
/// let encoder = JSONEncoder()
/// encoder.outputFormatting = .prettyPrinted
/// let prettyJSON = try user.encodedString(using: encoder)
/// // Result:
/// // {
/// //   "name": "John",
/// //   "age": 30
/// // }
///
/// // 5. Array encoding (for array types)
/// let users = [user, User(name: "Jane", age: 25)]
/// let array = try users.encodedArray()
/// // Result: [["name": "John", "age": 30], ["name": "Jane", "age": 25]]
/// ```
public extension Encodable {
    /// Encodes the object to `Data` using the specified JSON encoder.
    ///
    /// - Parameter encoder: The JSON encoder to use. Defaults to a new instance.
    /// - Returns: The encoded data.
    /// - Throws: An error if encoding fails.
    func encodedData(using encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    /// Encodes the object to a JSON string using the specified JSON encoder.
    ///
    /// - Parameter encoder: The JSON encoder to use. Defaults to a new instance.
    /// - Returns: The JSON string representation.
    /// - Throws: An error if encoding fails.
    func encodedString(using encoder: JSONEncoder = .init()) throws -> String {
        let data = try encodedData(using: encoder)
        return String(data: data, encoding: .utf8)!
    }
    
    /// Encodes the object to a dictionary using the specified JSON encoder.
    ///
    /// - Parameter encoder: The JSON encoder to use. Defaults to a new instance.
    /// - Returns: The dictionary representation.
    /// - Throws: An error if encoding fails or if the encoded object is not a dictionary.
    func encodedDict(using encoder: JSONEncoder = .init()) throws -> [String: Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
    
    /// Encodes the object to an array using the specified JSON encoder.
    ///
    /// - Parameter encoder: The JSON encoder to use. Defaults to a new instance.
    /// - Returns: The array representation.
    /// - Throws: An error if encoding fails or if the encoded object is not an array.
    func encodedArray(using encoder: JSONEncoder = .init()) throws -> [Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [Any]
    }
}
