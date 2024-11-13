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
            let attribute = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            return attribute == identifier
        }
    }
    
    func attributes(named identifier: String) -> [AttributeListSyntax.Element] {
        return filter {
            let attribute = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            return attribute == identifier
        }
    }
}
