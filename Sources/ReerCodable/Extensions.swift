//
//  Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/14.
//

import Foundation

extension String {
    var maybeNested: Bool {
        contains(".")
    }
    
    public var re_base64DecodedData: Data {
        get throws {
            if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
                return data
            }
            let remainder = self.count % 4
            var padding = ""
            if remainder > 0 {
                padding = String(repeating: "=", count: 4 - remainder)
            }
            if let data = Data(base64Encoded: self + padding, options: .ignoreUnknownCharacters) {
                return data
            } else {
                throw ReerCodableError(text: "Base64 decoded failed with string: \(self)")
            }
        }
    }
}

extension Data {
    public var re_bytes: [UInt8] {
        return [UInt8](self)
    }
}
