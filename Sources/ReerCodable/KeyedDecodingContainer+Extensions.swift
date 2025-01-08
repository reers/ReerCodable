//
//  Copyright © 2020 winddpan.
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

// MARK: - Decode

extension KeyedDecodingContainer where K == AnyCodingKey {
    public func decode<Value: Decodable>(
        type: Value.Type,
        keys: [String]
    ) throws -> Value {
        for key in keys {
            if key.maybeNested, let value = tryDecodeWithNestedKey(type: type, key: key) {
                return value
            } else if let value = tryDecodeWithNormalKey(type: type, key: key) {
                return value
            }
        }
        if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
            return valueType.init(nilLiteral: ()) as! Value
        }
        throw ReerCodableError(text: "Keys \(keys) not found or type not match or collection contains null.")
    }
    
    private func tryDecodeWithNormalKey<Value: Decodable>(
        type: Value.Type,
        key: String
    ) -> Value? {
        guard let key = AnyCodingKey(stringValue: key) else { return nil }
        if let value = try? decodeIfPresent(type, forKey: key) {
            return value
        }
        if let anyCodable = try? decodeIfPresent(AnyCodable.self, forKey: key) {
            let anyValue = anyCodable.value
            if let targetTypeValue = anyValue as? Value {
                return targetTypeValue
            }
            if let converted = (Value.self as? TypeConvertible.Type)?.convert(from: anyValue),
               let convertedValue = converted as? Value {
                return convertedValue
            }
        }
        return nil
    }
    
    private func tryDecodeWithNestedKey<Value: Decodable>(
        type: Value.Type,
        key: String
    ) -> Value? {
        let keyPath = key.components(separatedBy: ".")
        guard !keyPath.isEmpty else { return nil }
        
        guard
            let lastKey = keyPath.last,
            let container = try? nestedContainer(path: keyPath.dropLast())
        else {
            return nil
        }
        
        return container.tryDecodeWithNormalKey(type: type, key: lastKey)
    }
    
    public func match(keyPaths: [String]) -> Bool {
        for keyPath in keyPaths {
            if let containerAndKey = keyPath.containerAndKey,
               let foundValue = try? decode(type: String.self, keys: [containerAndKey.0]),
               foundValue == containerAndKey.1 {
                return true
            }
        }
        return false
    }
    
    public func nestedContainer(path: [String]) throws -> KeyedDecodingContainer<AnyCodingKey>? {
        guard let first = path.first else { return self }
        guard let key = AnyCodingKey(stringValue: first) else {
            return nil
        }
        let nestedContainer = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try nestedContainer.nestedContainer(path: Array(path.dropFirst()))
    }
    
    public func nestedContainer(keyPath: String) throws -> KeyedDecodingContainer<AnyCodingKey> {
        let path = keyPath.components(separatedBy: ".")
        guard let first = path.first else { return self }
        let key = AnyCodingKey(first)
        let nestedContainer = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        if let result = try nestedContainer.nestedContainer(path: Array(path.dropFirst())) {
            return result
        } else {
            throw ReerCodableError(text: "Nested container not found for key path \(keyPath)")
        }
    }
    
    public func nestedContainer(forKeys keys: String...) throws -> KeyedDecodingContainer<AnyCodingKey>? {
        for key in keys {
            if let container = try? nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey(key)) {
                return container
            }
        }
        return nil
    }
}

// MARK: - Decode Date

extension KeyedDecodingContainer where K == AnyCodingKey {
    public func decodeDate<Value: Decodable>(
        type: Value.Type,
        keys: [String],
        strategy: DateCodingStrategy
    ) throws -> Value {
        switch strategy {
        case .timeIntervalSince2001, .timeIntervalSince1970, .secondsSince1970, .millisecondsSince1970:
            return try decodeDateValue(type: type, keys: keys) { (rawValue: Double) in
                switch strategy {
                case .timeIntervalSince2001:
                    return Date(timeIntervalSinceReferenceDate: rawValue)
                case .timeIntervalSince1970, .secondsSince1970:
                    return Date(timeIntervalSince1970: rawValue)
                case .millisecondsSince1970:
                    return Date(timeIntervalSince1970: rawValue / 1000)
                default:
                    throw ReerCodableError(text: "Unreachable")
                }
            }
        case .iso8601:
            return try decodeDateValue(type: type, keys: keys) { (rawValue: String) in
                guard let date = DateCodingStrategy.iso8601Formatter.date(from: rawValue) else {
                    throw ReerCodableError(text: "Decode date with iso8601 string failed for keys: \(keys)")
                }
                return date
            }
        case .formatted(let dateFormatter):
            return try decodeDateValue(type: type, keys: keys) { (rawValue: String) in
                guard let date = dateFormatter.date(from: rawValue) else {
                    throw ReerCodableError(text: "Decode date with formatted string failed for keys: \(keys)")
                }
                return date
            }
        }
    }
    
    private func decodeDateValue<Value: Decodable, T: Decodable>(
        type: Value.Type,
        keys: [String],
        transform: (T) throws -> Date
    ) throws -> Value {
        if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
            guard let rawValue = try decode(type: T?.self, keys: keys) else {
                return valueType.init(nilLiteral: ()) as! Value
            }
            return try transform(rawValue) as! Value
        } else {
            let rawValue = try decode(type: T.self, keys: keys)
            return try transform(rawValue) as! Value
        }
    }
}

// MARK: - Compact Decode Array

extension KeyedDecodingContainer where K == AnyCodingKey {
    
    public func compactDecodeArray<Element: Decodable>(
        type: [Element].Type,
        keys: [String]
    ) throws -> [Element] {
        for key in keys {
            if key.maybeNested, let value: [Element] = try? tryDecodeArrayWithNestedKey(key) {
                return value
            } else if let value: [Element] = try? tryDecodeArrayWithNormalKey(key) {
                return value
            }
        }
        throw ReerCodableError(text: "Keys not found or type not match: \(keys) when compact decoding array.")
    }
    
    private func tryDecodeArrayWithNormalKey<Element: Decodable>(_ key: String) throws -> [Element] {
        var arrayContainer = try nestedUnkeyedContainer(forKey: AnyCodingKey(stringValue: key)!)
        var tempArray: [Element] = []
        while !arrayContainer.isAtEnd {
            if let element = try? arrayContainer.decode(Element.self) {
                tempArray.append(element)
            } else {
                _ = try? arrayContainer.superDecoder()
            }
        }
        return tempArray
    }
    
    private func tryDecodeArrayWithNestedKey<Element: Decodable>(_ key: String) throws -> [Element] {
        let keyPath = key.components(separatedBy: ".")
        guard !keyPath.isEmpty else {
            throw ReerCodableError(text: "Key path invalid.")
        }
        guard
            let lastKey = keyPath.last,
            let container = try? nestedContainer(path: keyPath.dropLast())
        else {
            throw ReerCodableError(text: "Get nested container failed.")
        }
        return try container.tryDecodeArrayWithNormalKey(lastKey)
    }
}

// MARK: - Compact Decode Dictionary

extension KeyedDecodingContainer where K == AnyCodingKey {
    
    public func compactDecodeDictionary<Key: Hashable & Decodable, Value: Decodable>(
        type: [Key: Value].Type,
        keys: [String]
    ) throws -> [Key: Value] {
        for key in keys {
            if key.maybeNested, let value: [Key: Value] = try? tryDecodeDictionaryWithNestedKey(key) {
                return value
            } else if let value: [Key: Value] = try? tryDecodeDictionaryWithNormalKey(key) {
                return value
            }
        }
        throw ReerCodableError(text: "Keys not found or type not match: \(keys) when compact decoding dictionary.")
    }
    
    private func tryDecodeDictionaryWithNormalKey<Key: Hashable & Decodable, Value: Decodable>(_ key: String) throws -> [Key: Value] {
        let dictContainer = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey(stringValue: key)!)
        var tempDict: [Key: Value] = [:]
        
        for key in dictContainer.allKeys {
            if let keyValue = try? Key(from: KeyDecoder(key.stringValue)),
               let value = try? dictContainer.decode(Value.self, forKey: key) {
                tempDict[keyValue] = value
            }
        }
        return tempDict
    }
    
    private func tryDecodeDictionaryWithNestedKey<Key: Hashable & Decodable, Value: Decodable>(_ key: String) throws -> [Key: Value] {
        let keyPath = key.components(separatedBy: ".")
        guard !keyPath.isEmpty else {
            throw ReerCodableError(text: "Key path invalid.")
        }
        guard
            let lastKey = keyPath.last,
            let container = try? nestedContainer(path: keyPath.dropLast())
        else {
            throw ReerCodableError(text: "Get nested container failed.")
        }
        return try container.tryDecodeDictionaryWithNormalKey(lastKey)
    }
}

// 用于将字符串转换为键类型的辅助解码器
private struct KeyDecoder: Decoder {
    let codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey: Any] = [:]
    let value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.typeMismatch(Key.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Not a keyed container"))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Not an unkeyed container"))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueContainer(value)
    }
    
    private struct SingleValueContainer: SingleValueDecodingContainer {
        let codingPath: [CodingKey] = []
        let value: String
        
        init(_ value: String) {
            self.value = value
        }
        
        func decodeNil() -> Bool { false }
        func decode(_ type: String.Type) throws -> String { value }
        func decode(_ type: Bool.Type) throws -> Bool { Bool(value) ?? false }
        func decode(_ type: Int.Type) throws -> Int { Int(value) ?? 0 }
        func decode(_ type: Int8.Type) throws -> Int8 { Int8(value) ?? 0 }
        func decode(_ type: Int16.Type) throws -> Int16 { Int16(value) ?? 0 }
        func decode(_ type: Int32.Type) throws -> Int32 { Int32(value) ?? 0 }
        func decode(_ type: Int64.Type) throws -> Int64 { Int64(value) ?? 0 }
        func decode(_ type: UInt.Type) throws -> UInt { UInt(value) ?? 0 }
        func decode(_ type: UInt8.Type) throws -> UInt8 { UInt8(value) ?? 0 }
        func decode(_ type: UInt16.Type) throws -> UInt16 { UInt16(value) ?? 0 }
        func decode(_ type: UInt32.Type) throws -> UInt32 { UInt32(value) ?? 0 }
        func decode(_ type: UInt64.Type) throws -> UInt64 { UInt64(value) ?? 0 }
        func decode(_ type: Float.Type) throws -> Float { Float(value) ?? 0 }
        func decode(_ type: Double.Type) throws -> Double { Double(value) ?? 0 }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Type not supported"))
        }
    }
}
