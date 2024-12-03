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
        var container = try nestedContainer(path: keyPath.dropLast())
        try container.encode(value, forNormalKey: lastKey)
    }
    
    private mutating func encode(_ value: Encodable, forNormalKey key: String) throws {
        let codingKey = AnyCodingKey(stringValue: key)!
        try encode(value, forKey: codingKey)
    }
    
    private mutating func nestedContainer(path: [String]) throws -> KeyedEncodingContainer<AnyCodingKey> {
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
        try encodeDateValue(value, key: key, treatDotAsNested: treatDotAsNested) { date in
            switch strategy {
            case .timeIntervalSince2001:
                return date.timeIntervalSinceReferenceDate
            case .timeIntervalSince1970:
                return date.timeIntervalSince1970
            case .secondsSince1970:
                return Int64(date.timeIntervalSince1970)
            case .millisecondsSince1970:
                return Int64(date.timeIntervalSince1970 * 1000)
            case .iso8601:
                return DateCodingStrategy.iso8601Formatter.string(from: date)
            case .formatted(let dateFormatter):
                return dateFormatter.string(from: date)
            }
        }
    }
    
    private mutating func encodeDateValue<Value: Encodable>(
        _ value: Value,
        key: String,
        treatDotAsNested: Bool = true,
        transform: (Date) -> Encodable
    ) throws {
        if Value.self is ExpressibleByNilLiteral.Type {
            if let date = value as? Date {
                try? encode(value: transform(date), key: key, treatDotAsNested: treatDotAsNested)
            }
        } else {
            let date = value as! Date
            try encode(value: transform(date), key: key, treatDotAsNested: treatDotAsNested)
        }
    }
}
