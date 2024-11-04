//
//  ReerCodableError.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/4.
//

public struct ReerCodableError: Error, CustomStringConvertible {
    public let text: String
    public var description: String { return text }
}
