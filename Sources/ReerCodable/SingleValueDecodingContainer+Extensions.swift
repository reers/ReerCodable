//
//  SingleValueDecodingContainer+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/22.
//

extension SingleValueDecodingContainer {
    public func decode<Value: Decodable>(type: Value.Type, enumName: String) throws -> Value {
        if let value = try? decode(Value.self) {
            return value
        }
        if let anyCodable = try? decode(AnyCodable.self) {
            let anyValue = anyCodable.value
            if let targetTypeValue = anyValue as? Value {
                return targetTypeValue
            }
            if let converted = (Value.self as? TypeConvertible.Type)?.convert(from: anyValue),
               let convertedValue = converted as? Value {
                return convertedValue
            }
        }
        throw ReerCodableError(text: "Enum case \(enumName) not match or type not match.")
    }
}
