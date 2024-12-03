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

enum SwiftType {
    case array(elementType: String, optional: Bool)
    case dictionary(keyType: String, valueType: String, optional: Bool)
    case set(elementType: String, optional: Bool)
    case simple(type: String, optional: Bool)
}

// MARK: - Type Checking Extensions
extension SwiftType {
    var isArray: Bool {
        if case .array(_, _) = self {
            return true
        }
        return false
    }
    
    var isDictionary: Bool {
        if case .dictionary(_, _, _) = self {
            return true
        }
        return false
    }
    
    var isSet: Bool {
        if case .set(_, _) = self {
            return true
        }
        return false
    }
    
    var isOptional: Bool {
        switch self {
        case .array(_, let optional),
             .dictionary(_, _, let optional),
             .set(_, let optional),
             .simple(_, let optional):
            return optional
        }
    }
}

func parseSwiftType(_ typeString: String) -> SwiftType {
    // 去除空格
    let type = typeString.replacingOccurrences(of: " ", with: "")
    
    // 检查是否是可选类型
    let isOptional = type.hasSuffix("?") || type.hasPrefix("Optional<")
    var cleanType = type
    
    // 处理可选类型
    if isOptional {
        if type.hasSuffix("?") {
            cleanType = String(type.dropLast())
        } else if type.hasPrefix("Optional<") {
            cleanType = String(type.dropFirst(9).dropLast())
        }
    }
    
    return parseBaseType(cleanType, optional: isOptional)
}

private func parseBaseType(_ type: String, optional: Bool) -> SwiftType {
    // 处理泛型数组 Array<T>
    if type.hasPrefix("Array<") && type.hasSuffix(">") {
        let elementType = String(type.dropFirst(6).dropLast())
        return .array(elementType: elementType, optional: optional)
    }
    
    // 处理Set类型 Set<T>
    if type.hasPrefix("Set<") && type.hasSuffix(">") {
        let elementType = String(type.dropFirst(4).dropLast())
        return .set(elementType: elementType, optional: optional)
    }
    
    // 处理泛型字典 Dictionary<K,V>
    if type.hasPrefix("Dictionary<") && type.hasSuffix(">") {
        let types = String(type.dropFirst(11).dropLast()).split(separator: ",")
        if types.count == 2 {
            return .dictionary(keyType: String(types[0]),
                             valueType: String(types[1]),
                             optional: optional)
        }
    }
    
    // 处理 [...] 格式
    if type.hasPrefix("[") && type.hasSuffix("]") {
        let inner = String(type.dropFirst().dropLast())
        
        // 查找顶层的冒号
        var bracketCount = 0
        var colonIndex: String.Index?
        
        for (index, char) in inner.enumerated() {
            if char == "[" {
                bracketCount += 1
            } else if char == "]" {
                bracketCount -= 1
            } else if char == ":" && bracketCount == 0 {
                colonIndex = inner.index(inner.startIndex, offsetBy: index)
                break
            }
        }
        
        // 如果找到顶层冒号，说明是字典
        if let colonIndex = colonIndex {
            let keyType = String(inner[..<colonIndex])
            let valueType = String(inner[inner.index(after: colonIndex)...])
            return .dictionary(keyType: keyType,
                             valueType: valueType,
                             optional: optional)
        }
        
        // 不包含顶层冒号则为数组
        return .array(elementType: inner, optional: optional)
    }
    
    // 简单类型
    return .simple(type: type, optional: optional)
}

extension String {
    
    var nonOptionalType: String {
        let trimmed = trimmingCharacters(in: .whitespaces)
        if trimmed.hasSuffix("?") {
            return String(trimmed.dropLast())
        }
        if trimmed.hasPrefix("Optional<") && trimmed.hasSuffix(">") {
            return String(trimmed.dropFirst(9).dropLast())
        }
        return trimmed
    }
    
    var setElement: String {
        let trimmed = trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("Set<") && trimmed.hasSuffix(">") {
            return String(trimmed.dropFirst(4).dropLast())
        }
        return trimmed
    }
}
