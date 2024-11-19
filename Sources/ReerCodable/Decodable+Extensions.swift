//
//  Decodable+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

import Foundation

public extension Decodable {
    static func decoded(
        from data: Data,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from string: String,
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = Data(string.utf8)
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from dict: [String: Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
    
    static func decoded(
        from array: [Any],
        using decoder: JSONDecoder = .init(),
        as type: Self.Type = Self.self
    ) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
        return try decoder.decode(type, from: data)
    }
}


public extension Data {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try decoder.decode(type, from: self)
    }
}

public extension String {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        return try Data(self.utf8).decoded(using: decoder, as: type)
    }
}

public extension Dictionary {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}

public extension Array {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init(), as type: T.Type = T.self) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return try data.decoded(using: decoder, as: type)
    }
}

