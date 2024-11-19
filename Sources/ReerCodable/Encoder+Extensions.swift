//
//  Encoder+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/19.
//

public extension Encoder {
    subscript<T: Encodable>(key: String, treatDotAsNested: Bool = true) -> T? {
        get { return nil }
        nonmutating set {
            var container = container(keyedBy: AnyCodingKey.self)
            try? container.encode(value: newValue, key: key, treatDotAsNested: treatDotAsNested)
        }
    }
}
