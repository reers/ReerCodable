//
//  KeyedDecodingContainer+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/15.
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

// MARK: - Decode Date

extension KeyedDecodingContainer where K == AnyCodingKey {
    public func decodeDate<Value: Decodable>(
        type: Value.Type,
        keys: [String],
        strategy: DateCodingStrategy
    ) throws -> Value {
        switch strategy {
        case .timeIntervalSince2001:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let timeInterval = try decode(type: Double?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return Date(timeIntervalSinceReferenceDate: timeInterval) as! Value
            } else {
                let timeInterval = try decode(type: Double.self, keys: keys)
                return Date(timeIntervalSinceReferenceDate: timeInterval) as! Value
            }
        case .timeIntervalSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let timeInterval = try decode(type: Double?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return Date(timeIntervalSince1970: timeInterval) as! Value
            } else {
                let timeInterval = try decode(type: Double.self, keys: keys)
                return Date(timeIntervalSince1970: timeInterval) as! Value
            }
        case .secondsSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let timeInterval = try decode(type: Double?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return Date(timeIntervalSince1970: timeInterval) as! Value
            } else {
                let timeInterval = try decode(type: Double.self, keys: keys)
                return Date(timeIntervalSince1970: timeInterval) as! Value
            }
        case .millisecondsSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let milliseconds = try decode(type: Double?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return Date(timeIntervalSince1970: milliseconds / 1000) as! Value
            } else {
                let milliseconds = try decode(type: Double.self, keys: keys)
                return Date(timeIntervalSince1970: milliseconds / 1000) as! Value
            }
        case .iso8601:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let iso8601String = try decode(type: String?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return DateCodingStrategy.iso8601Formatter.date(from: iso8601String) as! Value
            } else {
                let iso8601String = try decode(type: String.self, keys: keys)
                if let date = DateCodingStrategy.iso8601Formatter.date(from: iso8601String) {
                    return date as! Value
                }
                throw ReerCodableError(text: "Decode date with iso8601 string failed for keys: \(keys)")
            }
        case .formatted(let dateFormatter):
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                guard let formattedString = try decode(type: String?.self, keys: keys) else {
                    return valueType.init(nilLiteral: ()) as! Value
                }
                return dateFormatter.date(from: formattedString) as! Value
            } else {
                let formattedString = try decode(type: String.self, keys: keys)
                if let date = dateFormatter.date(from: formattedString) {
                    return date as! Value
                }
                throw ReerCodableError(text: "Decode date with formatted string failed for keys: \(keys)")
            }
        }
    }
}
