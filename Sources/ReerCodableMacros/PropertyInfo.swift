//
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
    var customDecoder: String?
    var customEncoder: String?
    var customByType: String?
    var isFlexibleType = false
    
    var codingKeys: [String] {
        var result: [String] = keys
        if !caseStyles.isEmpty {
            let convertedKey = KeyConverter.convert(value: name, caseStyles: caseStyles)
            result.append(contentsOf: convertedKey.map { "\"\($0)\"" })
        }
        if result.isEmpty {
            result.append("\"\(name)\"")
        }
        
        return result.reduce(into: [String]()) { array, element in
            let anyKey = "AnyCodingKey(\(element), \(element.hasDot))"
            if !array.contains(anyKey) {
                array.append(anyKey)
            }
        }
    }
    
    var stringCodingKeys: [String] {
        var result: [String] = keys
        if !caseStyles.isEmpty {
            let convertedKey = KeyConverter.convert(value: name, caseStyles: caseStyles)
            result.append(contentsOf: convertedKey.map { "\"\($0)\"" })
        }
        if result.isEmpty {
            result.append("\"\(name)\"")
        }
        
        return result.reduce(into: [String]()) { array, element in
            if !array.contains(element) {
                array.append(element)
            }
        }
    }
    
    var defaultValue: String? {
        return type.typeDefaultValue
    }
    
    
    var questionMark: String { isOptional ? "?" : "" }
}
