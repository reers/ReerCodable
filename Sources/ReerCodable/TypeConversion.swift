//
//  Copyright © 2020 winddpan.
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

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

protocol TypeConvertible {
    static func convert(from object: Any) -> Self?
}

// MARK: - To Bool

extension Bool: TypeConvertible {
    static func convert(from object: Any) -> Bool? {
        if let stringConvertible = object as? CustomStringConvertible,
           let double = Double(stringConvertible.description) {
            return double != .zero
        } else if let int = object as? Int {
            return int != 0
        } else if let string = object as? String {
            switch string.lowercased() {
            case "true", "yes":
                return true
            case "false", "no":
                return false
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: - To Integer

protocol IntegerConvertible: FixedWidthInteger, TypeConvertible {}

extension Int: IntegerConvertible {}
extension Int8: IntegerConvertible {}
extension Int16: IntegerConvertible {}
extension Int32: IntegerConvertible {}
extension Int64: IntegerConvertible {}
extension UInt: IntegerConvertible {}
extension UInt8: IntegerConvertible {}
extension UInt16: IntegerConvertible {}
extension UInt32: IntegerConvertible {}
extension UInt64: IntegerConvertible {}

#if compiler(>=6.0)
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension Int128: IntegerConvertible {}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension UInt128: IntegerConvertible {}
#endif

extension IntegerConvertible {
    static func convert(from object: Any) -> Self? {
        switch object {
        case let text as String:
            return Self(text, radix: 10)
        case let bool as Bool:
            return bool ? 1 : 0
        default:
            return nil
        }
    }
}

// MARK: - To Float or Double

protocol FloatConvertible: LosslessStringConvertible, TypeConvertible {}

extension Float: FloatConvertible {}
extension Double: FloatConvertible {}

extension FloatConvertible {
    static func convert(from object: Any) -> Self? {
        switch object {
        case let string as String:
            return Self(string)
        case let bool as Bool:
            return (bool ? 1.0 : 0) as? Self
        default:
            return nil
        }
    }
}

// MARK: - To CGFloat

#if canImport(CoreGraphics) || os(Linux) || os(Windows)
extension CGFloat: TypeConvertible {
    static func convert(from object: Any) -> CGFloat? {
        if let convertible = object as? CustomStringConvertible,
           let double = Double(convertible.description) {
            return CGFloat(double)
        } else if let bool = object as? Bool {
            return CGFloat(bool ? 1 : 0)
        } else if let double = object as? Double {
            return CGFloat(double)
        } else if let float = object as? Float {
            return CGFloat(float)
        } else {
            return nil
        }
    }
}
#endif

// MARK: - To String

extension String: TypeConvertible {
    static func convert(from object: Any) -> String? {
        switch object {
        case let string as String:
            return string
        case let int as Int:
            return int.description
        case let double as Double:
            return double.description
        case let bool as Bool:
            return bool ? "true" : "false"
        default:
            return nil
        }
    }
}

// MARK: - To Optional

extension Optional: TypeConvertible {
    static func convert(from object: Any) -> Optional<Wrapped>? {
        if let value = (Wrapped.self as? TypeConvertible.Type)?.convert(from: object) as? Wrapped {
            return Optional(value)
        } else if let value = object as? Wrapped {
            return Optional(value)
        }
        return nil
    }
}
