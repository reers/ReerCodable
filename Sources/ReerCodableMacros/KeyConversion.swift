//
//  KeyConversion.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/13.
//
enum WordCase {
    case lowerCase
    case camelCase
    case pascalCase
    case upperCase
}

struct KeyConvertor {
    private static let snakeConverter = KeyConvertor(separator: "_")
    private static let kebabConverter = KeyConvertor(separator: "-")
    private static let plainConverter = KeyConvertor(separator: "")
    
    let separator: String

    init(separator: String) {
        self.separator = separator
    }
    
    /// 批量转换多个样式
    static func convert(value: String, caseStyles: [CaseStyle]) -> [String] {
        return caseStyles.map { convert(value: value, caseStyle: $0) }
    }
    
    /// 转换单个样式
    static func convert(value: String, caseStyle: CaseStyle) -> String {
        switch caseStyle {
        case .flatCase:
            return plainConverter.convert(value: value, variant: .lowerCase)
            
        case .upperCase:
            return plainConverter.convert(value: value, variant: .upperCase)
            
        case .camelCase:
            return plainConverter.convert(value: value, wordCase: .camelCase)
            
        case .pascalCase:
            return plainConverter.convert(value: value, wordCase: .pascalCase)
            
        case .snakeCase:
            return snakeConverter.convert(value: value, wordCase: .lowerCase)
            
        case .kebabCase:
            return kebabConverter.convert(value: value, wordCase: .lowerCase)
            
        case .camelSnakeCase:
            return snakeConverter.convert(value: value, wordCase: .camelCase)
            
        case .pascalSnakeCase:
            return snakeConverter.convert(value: value, wordCase: .pascalCase)
            
        case .screamingSnakeCase:
            return snakeConverter.convert(value: value, wordCase: .upperCase)
            
        case .camelKebabCase:
            return kebabConverter.convert(value: value, wordCase: .camelCase)
            
        case .pascalKebabCase:
            return kebabConverter.convert(value: value, wordCase: .pascalCase)
            
        case .screamingKebabCase:
            return kebabConverter.convert(value: value, wordCase: .upperCase)
        }
    }
    
    func convert(value: String, wordCase: WordCase) -> String {
        // Remove any special characters at the beginning/end
        let isAllCaps = value.isAllCaps
        let firstAlphanumericIndex = value.firstIndex(where: \.isAlphaNumeric) ?? value.startIndex
        let lastAlphanumericIndex = value.lastIndex(where: \.isAlphaNumeric) ?? value.endIndex
        let preparedString = value[firstAlphanumericIndex...lastAlphanumericIndex]

        var resultString = ""
        var i = 0
        while i < preparedString.count {
            let index = preparedString.index(preparedString.startIndex, offsetBy: i)
            let character = preparedString[index]
            var hasHaddedSeparator = false

            if i >= 1, (!character.isAlphaNumeric || (character.isUppercase && !isAllCaps)) {
                resultString += separator
                hasHaddedSeparator = true
            }

            guard let nextCharacter = {
                if character.isAlphaNumeric {
                    return character
                } else if index == preparedString.endIndex {
                    return nil
                } else {
                    i += 1
                    return preparedString[preparedString.index(after: index)]
                }
            }() else {
                continue
            }
            switch variant {
            case .lowerCase:
                resultString += String(nextCharacter).lowercased()
            case .upperCase:
                resultString += String(nextCharacter).uppercased()
            case .camelCase:
                resultString += hasHaddedSeparator ? String(nextCharacter).uppercased() :  String(nextCharacter).lowercased()
            case .pascalCase:
                resultString += hasHaddedSeparator || i == 0 ? String(nextCharacter).uppercased() :  String(nextCharacter).lowercased()
            }
            i += 1
        }
        return resultString
    }
}

private extension Character {
    var isAlphaNumeric: Bool {
        return isLetter || isNumber
    }
}

private extension String {
    var isAllCaps: Bool {
        first { $0.isAlphaNumeric && $0.isLowercase } == nil
    }
}
