//
//  KeyedCodingContainer+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/4.
//

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
        throw ReerCodableError(text: "Keys not found or type not match: \(keys)")
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
            let container = try? getNestedContainer(path: keyPath.dropLast())
        else {
            return nil
        }
        
        return container.tryDecodeWithNormalKey(type: type, key: lastKey)
    }
    
    private func getNestedContainer(path: [String]) throws -> KeyedDecodingContainer<AnyCodingKey>? {
        guard let first = path.first else { return self }
        guard let key = AnyCodingKey(stringValue: first) else {
            return nil
        }
        let nestedContainer = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try nestedContainer.getNestedContainer(path: Array(path.dropFirst()))
    }
}

// MARK: - Encode

extension KeyedEncodingContainer where K == AnyCodingKey {
    public mutating func encode<Value: Encodable>(
        value: Value,
        key: String,
        treatDotAsNested: Bool = true
    ) throws {
        if case Optional<Any>.none = (value as Any) {
            return
        }
        if treatDotAsNested, key.maybeNested {
            try encode(value, forNestedKey: key)
        } else {
            try encode(value, forNormalKey: key)
        }
    }
    
    private mutating func encode(_ value: Encodable, forNestedKey key: String) throws {
        let keyPath = key.components(separatedBy: ".")
        guard let lastKey = keyPath.last, !lastKey.isEmpty else {
            throw ReerCodableError(text: "Nested key (\(key)) invalid.")
        }
        var container = try getNestedContainer(path: keyPath.dropLast())
        try container.encode(value, forNormalKey: lastKey)
    }
    
    private mutating func encode(_ value: Encodable, forNormalKey key: String) throws {
        let codingKey = AnyCodingKey(stringValue: key)!
        try encode(value, forKey: codingKey)
    }
    
    private mutating func getNestedContainer(path: [String]) throws -> KeyedEncodingContainer<AnyCodingKey> {
        var container = self
        for pathKey in path {
            let codingKey = AnyCodingKey(stringValue: pathKey)!
            container = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: codingKey)
        }
        return container
    }
}

// MARK: - Extensions

extension String {
    var maybeNested: Bool {
        contains(".")
    }
}
