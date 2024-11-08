//
//  File.swift
//  
//
//  Created by phoenix on 2024/10/16.
//

import Foundation

struct MacroError: Error, CustomStringConvertible {
    public let text: String
    public var description: String { return text }
}
