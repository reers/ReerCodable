//
//  Copyright © 2024 GottaGetSwifty.
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

enum WordCase {
    case lowerCase
    case camelCase
    case pascalCase
    case upperCase
}

enum WordSeparator: String {
    case snake = "_"
    case kebab = "-"
    case plain = ""
}

struct KeyConverter {
    
    static func convert(value: String, caseStyles: [CaseStyle]) -> [String] {
        return caseStyles.map { convert(value: value, caseStyle: $0) }
    }
    
    static func convert(value: String, caseStyle: CaseStyle) -> String {
        switch caseStyle {
        case .flatCase:
            return convert(value: value, wordCase: .lowerCase, separator: .plain)
        case .upperCase:
            return convert(value: value, wordCase: .upperCase, separator: .plain)
        case .camelCase:
            return convert(value: value, wordCase: .camelCase, separator: .plain)
        case .pascalCase:
            return convert(value: value, wordCase: .pascalCase, separator: .plain)
        case .snakeCase:
            return convert(value: value, wordCase: .lowerCase, separator: .snake)
        case .kebabCase:
            return convert(value: value, wordCase: .lowerCase, separator: .kebab)
        case .camelSnakeCase:
            return convert(value: value, wordCase: .camelCase, separator: .snake)
        case .pascalSnakeCase:
            return convert(value: value, wordCase: .pascalCase, separator: .snake)
        case .screamingSnakeCase:
            return convert(value: value, wordCase: .upperCase, separator: .snake)
        case .camelKebabCase:
            return convert(value: value, wordCase: .camelCase, separator: .kebab)
        case .pascalKebabCase:
            return convert(value: value, wordCase: .pascalCase, separator: .kebab)
        case .screamingKebabCase:
            return convert(value: value, wordCase: .upperCase, separator: .kebab)
        }
    }
    
    static func convert(value: String, wordCase: WordCase, separator: WordSeparator) -> String {
        let isAllCaps = value.isAllCaps
        let firstAlphanumericIndex = value.firstIndex(where: \.isAlphaNumeric) ?? value.startIndex
        let lastAlphanumericIndex = value.lastIndex(where: \.isAlphaNumeric) ?? value.endIndex
        let preparedString = value[firstAlphanumericIndex...lastAlphanumericIndex]

        var resultString = ""
        var i = 0
        while i < preparedString.count {
            let index = preparedString.index(preparedString.startIndex, offsetBy: i)
            let character = preparedString[index]
            var hasAddedSeparator = false

            // 检查是否需要添加分隔符
            if i > 0 {
                let previousIndex = preparedString.index(before: index)
                let previousCharacter = preparedString[previousIndex]

                // 如果当前字符是大写字母，且不是连续大写字母的开头，则添加分隔符
                // 连续大写字母的开头指：前一个字符不是大写字母或前一个字符不是字母数字
                // 另外，如果当前是大写，下一个是小写，也要添加分隔符
                if character.isUppercase && (!isAllCaps && ( !previousCharacter.isUppercase || !previousCharacter.isAlphaNumeric)) {
                    resultString += separator.rawValue
                    hasAddedSeparator = true
                } else if !character.isAlphaNumeric {
                    resultString += separator.rawValue
                    hasAddedSeparator = true
                } else if character.isUppercase && i + 1 < preparedString.count {
                    let nextIndex = preparedString.index(after: index)
                    let nextCharacter = preparedString[nextIndex]
                    if nextCharacter.isLowercase {
                        resultString += separator.rawValue
                        hasAddedSeparator = true
                    }
                }
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

            switch wordCase {
            case .lowerCase:
                resultString += String(nextCharacter).lowercased()
            case .upperCase:
                resultString += String(nextCharacter).uppercased()
            case .camelCase:
                resultString += hasAddedSeparator
                    ? String(nextCharacter).uppercased()
                    : String(nextCharacter).lowercased()
            case .pascalCase:
                resultString += hasAddedSeparator || i == 0
                    ? String(nextCharacter).uppercased()
                    : String(nextCharacter).lowercased()
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
        return first { $0.isAlphaNumeric && $0.isLowercase } == nil
    }
}
