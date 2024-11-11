//
//  TypeConversion.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/11.
//

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

protocol IntegerConvertable: FixedWidthInteger, TypeConvertible {}

extension Int: IntegerConvertable {}
extension Int8: IntegerConvertable {}
extension Int16: IntegerConvertable {}
extension Int32: IntegerConvertable {}
extension Int64: IntegerConvertable {}
extension UInt: IntegerConvertable {}
extension UInt8: IntegerConvertable {}
extension UInt16: IntegerConvertable {}
extension UInt32: IntegerConvertable {}
extension UInt64: IntegerConvertable {}

extension IntegerConvertable {
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

protocol FloatConvertable: LosslessStringConvertible, TypeConvertible {}

extension Float: FloatConvertable {}
extension Double: FloatConvertable {}

extension FloatConvertable {
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
