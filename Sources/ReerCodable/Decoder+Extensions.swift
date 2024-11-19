//
//  Decoder+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

public extension Decoder {
    subscript<T: Decodable>(keys: [String]) -> T? {
        let container = try? container(keyedBy: AnyCodingKey.self)
        return try? container?.decode(type: T.self, keys: keys)
    }
    
    subscript<T: Decodable>(keys: String ...) -> T? {
        let container = try? container(keyedBy: AnyCodingKey.self)
        return try? container?.decode(type: T.self, keys: keys)
    }
}
