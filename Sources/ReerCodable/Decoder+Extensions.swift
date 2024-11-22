//
//  Decoder+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

public extension Decoder {
    func value<Value: Decodable>(forKeys keys: String...) throws -> Value {
        let container = try container(keyedBy: AnyCodingKey.self)
        return try container.decode(type: Value.self, keys: keys)
    }
}
