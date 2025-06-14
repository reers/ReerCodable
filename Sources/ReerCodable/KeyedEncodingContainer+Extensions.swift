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
        
        #if compiler(>=6.0)
        if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            if let int128 = value as? Int128 {
                let stringValue = String(describing: int128)
                try encode(stringValue, forKey: codingKey)
                return
            } else if let uint128 = value as? UInt128 {
                let stringValue = String(describing: uint128)
                try encode(stringValue, forKey: codingKey)
                return
            }
        }
        #endif
        
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
    
    public mutating func nestedContainer(keyPath: String) throws -> KeyedEncodingContainer<AnyCodingKey> {
        let path = keyPath.components(separatedBy: ".")
        return try nestedContainer(path: path)
    }
    
    public mutating func encode(keyPath: String, value: any Encodable) throws {
        try encode(value: value, key: keyPath, treatDotAsNested: true)
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
