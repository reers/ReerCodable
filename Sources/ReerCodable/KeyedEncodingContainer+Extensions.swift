//
//  KeyedEncodingContainer+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/15.
//

import Foundation

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

// MARK: - Encode Date

extension KeyedEncodingContainer where K == AnyCodingKey {
    public mutating func encodeDate<Value: Encodable>(
        value: Value,
        key: String,
        treatDotAsNested: Bool = true,
        strategy: DateCodingStrategy
    ) throws {
        switch strategy {
        case .timeIntervalSince2001:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: date.timeIntervalSinceReferenceDate, key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: date.timeIntervalSinceReferenceDate, key: key, treatDotAsNested: treatDotAsNested)
            }
        case .timeIntervalSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: date.timeIntervalSince1970, key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: date.timeIntervalSince1970, key: key, treatDotAsNested: treatDotAsNested)
            }
        case .secondsSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: Int64(date.timeIntervalSince1970), key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: Int64(date.timeIntervalSince1970), key: key, treatDotAsNested: treatDotAsNested)
            }
        case .millisecondsSince1970:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: Int64(date.timeIntervalSince1970 * 1000), key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: Int64(date.timeIntervalSince1970 * 1000), key: key, treatDotAsNested: treatDotAsNested)
            }
        case .iso8601:
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: DateCodingStrategy.iso8601Formatter.string(from: date), key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: DateCodingStrategy.iso8601Formatter.string(from: date), key: key, treatDotAsNested: treatDotAsNested)
            }
        case .formatted(let dateFormatter):
            if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                if let date = value as? Date {
                    try? encode(value: dateFormatter.string(from: date), key: key, treatDotAsNested: treatDotAsNested)
                }
            } else {
                let date = value as! Date
                try encode(value: dateFormatter.string(from: date), key: key, treatDotAsNested: treatDotAsNested)
            }
        }
    }
}
