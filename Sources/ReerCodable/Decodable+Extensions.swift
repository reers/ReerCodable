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

/// Extensions providing convenient decoding methods for various data types.
///
/// These extensions add methods to decode objects from:
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
/// // 1. Decode from JSON Data
/// let jsonData = """
/// {
///     "name": "John",
///     "age": 30
/// }
/// """.data(using: .utf8)!
/// let user1 = try User.decoded(from: jsonData)
/// // Or using instance method
/// let user1a = try jsonData.decoded(as: User.self)
///
/// // 2. Decode from JSON String
/// let jsonString = """
/// {
///     "name": "Jane",
///     "age": 25
/// }
/// """
/// let user2 = try User.decoded(from: jsonString)
/// // Or using instance method
/// let user2a = try jsonString.decoded(as: User.self)
///
/// // 3. Decode from Dictionary
/// let dict: [String: Any] = ["name": "Bob", "age": 35]
/// let user3 = try User.decoded(from: dict)
/// // Or using instance method
/// let user3a = try dict.decoded(as: User.self)
///
/// // 4. Decode from Array (for array types)
/// let arrayData = [
///     ["name": "John", "age": 30],
///     ["name": "Jane", "age": 25]
/// ]
/// let users = try [User].decoded(from: arrayData)
/// // Or using instance method
/// let usersa = try arrayData.decoded(as: [User].self)
///
/// // 5. Custom JSONDecoder
/// let decoder = JSONDecoder()
/// decoder.dateDecodingStrategy = .iso8601
/// let user5 = try User.decoded(from: jsonData, using: decoder)
/// ```
public extension Decodable {
    /// Decodes an instance from JSON Data.
    ///
    /// - Parameters:
    ///   - data: The JSON data to decode from
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as. Defaults to Self
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    static func decoded(
        from data: Data,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        return try decoder.decode(type, from: data)
    }
    
    /// Decodes an instance from a JSON string.
    ///
    /// - Parameters:
    ///   - string: The JSON string to decode from
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as. Defaults to Self
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    static func decoded(
        from string: String,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = Data(string.utf8)
        return try decoder.decode(type, from: data)
    }
    
    /// Decodes an instance from a dictionary.
    ///
    /// - Parameters:
    ///   - dict: The dictionary to decode from
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as. Defaults to Self
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    static func decoded(
        from dict: [String: Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        guard JSONSerialization.isValidJSONObject(dict) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "The provided dictionary is not a valid JSON object. Dictionary: \(dict)",
                )
            )
        }
        let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
    
    /// Decodes an instance from an array.
    ///
    /// - Parameters:
    ///   - array: The array to decode from
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as. Defaults to Self
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    static func decoded(
        from array: [Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        guard JSONSerialization.isValidJSONObject(array) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "The provided array is not a valid JSON object. Array: \(array)",
                )
            )
        }
        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
}

/// Extension to decode objects directly from Data.
public extension Data {
    /// Decodes the data to the specified type.
    ///
    /// - Parameters:
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try decoder.decode(type, from: self)
    }
}

/// Extension to decode objects directly from String.
public extension String {
    /// Decodes the string to the specified type.
    ///
    /// - Parameters:
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try Data(self.utf8).decoded(using: decoder, as: type)
    }
}

/// Extension to decode objects directly from Dictionary.
public extension Dictionary {
    /// Decodes the dictionary to the specified type.
    ///
    /// - Parameters:
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "The provided dictionary is not a valid JSON object. Dictionary: \(self)",
                )
            )
        }
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}

/// Extension to decode objects directly from Array.
public extension Array {
    /// Decodes the array to the specified type.
    ///
    /// - Parameters:
    ///   - decoder: The JSON decoder to use. Defaults to a new instance
    ///   - type: The type to decode as
    /// - Returns: A decoded instance
    /// - Throws: An error if decoding fails
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "The provided array is not a valid JSON object. Array: \(self)",
                )
            )
        }
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}
