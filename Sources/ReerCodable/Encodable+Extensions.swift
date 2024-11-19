//
//  Encodable+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

import Foundation

public extension Encodable {
    func encodedData(using encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    func encodedString(using encoder: JSONEncoder = .init()) throws -> String {
        let data = try encodedData(using: encoder)
        return String(data: data, encoding: .utf8)!
    }
    
    func encodedDict(using encoder: JSONEncoder = .init()) throws -> [String: Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
    
    func encodedArray(using encoder: JSONEncoder = .init()) throws -> [Any] {
        let data = try encodedData(using: encoder)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [Any]
    }
}
