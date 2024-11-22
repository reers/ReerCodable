//
//  Encoder+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

public extension Encoder {
    func set<Value: Encodable>(_ value: Value, forKey key: String, treatDotAsNested: Bool = true) throws {
        var container = container(keyedBy: AnyCodingKey.self)
        try container.encode(value: value, key: key, treatDotAsNested: treatDotAsNested)
    }
}
