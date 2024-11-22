//
//  AttributeListSyntax+Extensions.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/13.
//

import SwiftSyntax

extension AttributeListSyntax {
    func firstAttribute(named identifier: String) -> AttributeListSyntax.Element? {
        return first {
            guard let attribute = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            else { return false }
            return (attribute == identifier) || attribute.hasPrefix("\(identifier)<")
        }
    }
    
    func containsAttribute(named identifier: String) -> Bool {
        return firstAttribute(named: identifier) != nil
    }
}
