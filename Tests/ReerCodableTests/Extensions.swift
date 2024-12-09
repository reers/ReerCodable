//
//  Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/12/10.
//

import Foundation

enum JSONError: Error {
    case invalidDict
    case invalidArray
}

extension Data {
    var utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
    
    var jsonValue: Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
    
    func jsonValue(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }

    /// ReerKit: Returns an Dictionary for decoded self.
    /// Returns nil if an error occurs.
    var dictionary: [AnyHashable: Any]? {
        return try? toDictionary()
    }
    
    /// ReerKit: Returns [String: Any] for decoded self.
    /// Returns nil if an error occurs.
    var stringAnyDictionary: [String: Any]? {
        return try? toDictionary() as? [String: Any]
    }

    /// ReerKit: Returns an Dictionary for decoded self.
    func toDictionary() throws -> [AnyHashable: Any] {
        if let value = jsonValue, let dictionary = value as? [AnyHashable: Any] {
            return dictionary
        } else {
            throw JSONError.invalidDict
        }
    }
}

extension Optional where Wrapped == [String: Any] {
    func int(_ key: String) -> Int? {
        guard let self else { return nil }
        return self[key] as? Int
    }
    
    func bool(_ key: String) -> Bool? {
        guard let self else { return nil }
        return self[key] as? Bool
    }
    
    func double(_ key: String) -> Double? {
        guard let self else { return nil }
        return self[key] as? Double
    }
    
    func string(_ key: String) -> String? {
        guard let self else { return nil }
        return self[key] as? String
    }
}
