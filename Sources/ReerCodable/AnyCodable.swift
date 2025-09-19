//
//  Copyright © 2024 Flight-School.
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

#if canImport(Foundation)
import Foundation
#endif

public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int: 
            try container.encode(int)
        case let int8 as Int8: 
            try container.encode(int8)
        case let int16 as Int16: 
            try container.encode(int16)
        case let int32 as Int32: 
            try container.encode(int32)
        case let int64 as Int64: 
            try container.encode(int64)
        case let uint as UInt: 
            try container.encode(uint)
        case let uint8 as UInt8: 
            try container.encode(uint8)
        case let uint16 as UInt16: 
            try container.encode(uint16)
        case let uint32 as UInt32: 
            try container.encode(uint32)
        case let uint64 as UInt64: 
            try container.encode(uint64)
        case let float as Float: 
            try container.encode(float)
        case let double as Double: 
            try container.encode(double)
        case let string as String: 
            try container.encode(string)
        #if canImport(Foundation)
        case let date as Date: 
            try container.encode(date)
        case let url as URL: 
            try container.encode(url)
        #endif
        case let array as [Any]: 
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        case let encodable as Encodable: try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyEncodable value cannot be encoded"
            )
            #if compiler(>=6.0)
            if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                if let int128 = value as? Int128 {
                    try container.encode(int128)
                } else if let uint128 = value as? UInt128 {
                    try container.encode(uint128)
                } else {
                    throw EncodingError.invalidValue(value, context)
                }
            } else {
                throw EncodingError.invalidValue(value, context)
            }
            #else
            throw EncodingError.invalidValue(value, context)
            #endif
        }
    }
}

extension AnyCodable: Equatable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case is (NSNull, NSNull):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        default:
            #if compiler(>=6.0)
            if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                if let left = lhs.value as? Int128, let right = rhs.value as? Int128 {
                    return left == right
                } else if let left = lhs.value as? UInt128, let right = rhs.value as? UInt128 {
                    return left == right
                } else {
                    return false
                }
            } else {
                return false
            }
            #else
            return false
            #endif
        }
    }
}

extension AnyCodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch value {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Int8:
            hasher.combine(value)
        case let value as Int16:
            hasher.combine(value)
        case let value as Int32:
            hasher.combine(value)
        case let value as Int64:
            hasher.combine(value)
        case let value as UInt:
            hasher.combine(value)
        case let value as UInt8:
            hasher.combine(value)
        case let value as UInt16:
            hasher.combine(value)
        case let value as UInt32:
            hasher.combine(value)
        case let value as UInt64:
            hasher.combine(value)
        case let value as Float:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as [String: AnyCodable]:
            hasher.combine(value)
        case let value as [AnyCodable]:
            hasher.combine(value)
        default:
            #if compiler(>=6.0)
            if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                if let int128 = value as? Int128 {
                    hasher.combine(int128)
                } else if let uint128 = value as? UInt128 {
                    hasher.combine(uint128)
                } else {
                    break
                }
            } else {
                break
            }
            #else
            break
            #endif
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

// MARK: - AnyCodable Extensions

public extension AnyCodable {
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var bool: Bool? {
        return value as? Bool
    }
    
    var int: Int? {
        return value as? Int
    }
    
    var uint: UInt? {
        return value as? UInt
    }
    
    var double: Double? {
        return value as? Double
    }
    
    var string: String? {
        return value as? String
    }
    
    var dict: [String: Any]? {
        return value as? [String: Any]
    }
    
    var array: [Any]? {
        return value as? [Any]
    }
    
    var dictArray: [[String: Any]]? {
        return value as? [[String: Any]]
    }
    
    /// Returns a null AnyCodable instance
    static var null: AnyCodable {
        return AnyCodable(NSNull())
    }
    
    /// Checks if the value is null
    var isNull: Bool {
        return value is NSNull
    }
}


protocol JSONKey {}
/// Extends Int to conform to JSONKey for array index access
extension Int: JSONKey {}
/// Extends String to conform to JSONKey for dictionary key access
extension String: JSONKey {}

/// Core subscript method that handles both array index and dictionary key access.
///
/// This method provides type-safe access to nested JSON structures with automatic
/// null handling for invalid paths or out-of-bounds access. It uses O(1) bounds
/// checking for arrays and direct dictionary lookup.
///
/// - Parameter key: A JSONKey (Int for arrays, String for dictionaries)
/// - Returns: AnyCodable instance containing the value, or AnyCodable.null if not found
///
/// Time Complexity: O(1) for both array and dictionary access
///
/// Example:
/// ```swift
/// let json = AnyCodable([
///     "users": [
///         ["name": "Alice", "age": 25],
///         ["name": "Bob", "age": 30]
///     ],
///     "total": 2
/// ])
///
/// // Chained access for complex nested structures
/// let firstName = json["users"][0]["name"].string  // "Alice"
/// let secondAge = json["users"][1]["age"].int      // 30
/// let total = json["total"].int                    // 2
///
/// // Safe access to non-existent paths
/// let invalid = json["users"][5]["name"].isNull    // true
/// let missing = json["nonexistent"].isNull         // true
/// ```
extension AnyCodable {
    
    /// Convenient subscript for array index access.
    /// 
    /// Provides clean syntax for accessing array elements by index with automatic
    /// bounds checking. Returns `AnyCodable.null` for out-of-bounds access.
    /// 
    /// - Parameter index: The array index to access (0-based)
    /// - Returns: AnyCodable instance at the specified index, or AnyCodable.null if out of bounds
    /// 
    /// Example:
    /// ```swift
    /// let json = AnyCodable(["Alice", "Bob", "Charlie"])
    /// let first = json[0].string     // "Alice"
    /// let second = json[1].string    // "Bob" 
    /// let invalid = json[10].isNull  // true
    /// ```
    public subscript(index: Int) -> AnyCodable {
        return self[path: index]
    }
    
    /// Convenient subscript for dictionary key access.
    /// 
    /// Provides clean syntax for accessing dictionary values by string key.
    /// Returns `AnyCodable.null` if the key doesn't exist or if the current
    /// value is not a dictionary.
    /// 
    /// - Parameter key: The dictionary key to access
    /// - Returns: AnyCodable instance for the key, or AnyCodable.null if key doesn't exist
    /// 
    /// Example:
    /// ```swift
    /// let json = AnyCodable(["name": "Alice", "age": 25])
    /// let name = json["name"].string      // "Alice"
    /// let age = json["age"].int           // 25
    /// let invalid = json["missing"].isNull // true
    /// ```
    public subscript(key: String) -> AnyCodable {
        return self[path: key]
    }
    
    /// Single subscript access for array index or dictionary key
    subscript(path key: JSONKey) -> AnyCodable {
        switch key {
        case let index as Int:
            // Array index access with O(1) bounds checking
            if let array = value as? [Any], index >= 0 && index < array.count {
                return AnyCodable(array[index])
            }
            return .null
        case let key as String:
            // Dictionary key access with direct lookup
            if let dictionary = value as? [String: Any] {
                return AnyCodable(dictionary[key] ?? NSNull())
            }
            return .null
        default:
            return .null
        }
    }
}
