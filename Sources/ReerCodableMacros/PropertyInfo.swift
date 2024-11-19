//
//  PropertyInfo.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/15.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct PropertyInfo {
    var modifiers: DeclModifierListSyntax = []
    var name: String
    var type: String
    var isOptional = false
    var isIgnored = false
    var keys: [String] = []
    var encodingKey: String?
    var treatDotAsNestedWhenEncoding: Bool = true
    var initExpr: String?
    var base64Coding = false
    var caseStyles: [CaseStyle] = []
    var dateCodingStrategy: String?
    var isCompactDecoding = false
    
    var codingKeys: [String] {
        var result: [String] = keys
        if !caseStyles.isEmpty {
            let convertedKey = KeyConverter.convert(value: name, caseStyles: caseStyles)
            result.append(contentsOf: convertedKey.map { "\"\($0)\"" })
        }
        result.append("\"\(name)\"")
        
        return result.reduce(into: [String]()) { array, element in
            if !array.contains(element) {
                array.append(element)
            }
        }
    }
    
    var defaultValue: String? {
        let trimmed = type.trimmingCharacters(in: .whitespaces)
        if let defaultValue = Self.basicTypeDefaults[trimmed] {
            return defaultValue
        }
        if (trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
           || trimmed.hasPrefix("Set<") {
            return ".init()"
        }
        return nil
    }
    
    private static let basicTypeDefaults: [String: String] = [
        "Int": "0",
        "Int8": "0",
        "Int16": "0",
        "Int32": "0",
        "Int64": "0",
        "UInt": "0",
        "UInt8": "0",
        "UInt16": "0",
        "UInt32": "0",
        "UInt64": "0",
        "Bool": "false",
        "String": "\"\"",
        "Float": "0.0",
        "Double": "0.0"
    ]
    
    var questionMark: String { isOptional ? "?" : "" }
}
