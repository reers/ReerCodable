//
//  File.swift
//  
//
//  Created by phoenix on 2024/10/16.
//

import Foundation

struct MacroError: Error, CustomStringConvertible {
    let text: String
    var description: String { return text }
}
