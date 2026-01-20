//
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

import SwiftSyntax
import SwiftSyntaxMacros

public struct DateCoding: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self)
        else {
            throw MacroError(text: "@DateCoding macro is only for property.")
        }
        
        if let dateCoding = variable.attributes.firstAttribute(named: "DateCoding") {
            guard let type = variable.type else {
                return []
            }
            guard ["Date", "Date?"].contains(type) else {
                throw MacroError(text: "@DateCoding macro is only for `Date`.")
            }
            
            guard let attribute = dateCoding.as(AttributeSyntax.self),
                  let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else {
                throw MacroError(text: "@DateCoding macro requires a date coding strategy.")
            }
            
            let param = arguments.trimmedDescription
            if param.isEmpty {
                throw MacroError(text: "@DateCoding macro requires a date coding strategy.")
            }
            
            // Validate iso8601WithOptions parameters
            try validateISO8601Options(arguments: arguments)
        }
        return []
    }
    
    /// Validate time zone offset ranges for iso8601WithOptions
    private static func validateISO8601Options(arguments: LabeledExprListSyntax) throws {
        for argument in arguments {
            let expr = argument.expression
            
            // Check for timeZone parameter
            if argument.label?.text == "timeZone" {
                try validateTimeZoneStyle(expr)
            }
            
            // Check for nested function call like .iso8601WithOptions(...)
            if let functionCall = expr.as(FunctionCallExprSyntax.self) {
                for arg in functionCall.arguments {
                    if arg.label?.text == "timeZone" {
                        try validateTimeZoneStyle(arg.expression)
                    }
                }
            }
        }
    }
    
    /// Validate TimeZoneStyle parameter values
    private static func validateTimeZoneStyle(_ expr: ExprSyntax) throws {
        // Handle .offsetHours(n) or .offsetSeconds(n)
        if let functionCall = expr.as(FunctionCallExprSyntax.self),
           let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {
            let memberName = memberAccess.declName.baseName.text
            
            if memberName == "offsetHours" {
                if let firstArg = functionCall.arguments.first,
                   let intValue = extractIntegerValue(from: firstArg.expression) {
                    // Valid range: -12 to +14
                    if intValue < -12 || intValue > 14 {
                        throw MacroError(text: "offsetHours must be between -12 and 14, got \(intValue)")
                    }
                }
            } else if memberName == "offsetSeconds" {
                if let firstArg = functionCall.arguments.first,
                   let intValue = extractIntegerValue(from: firstArg.expression) {
                    // Valid range: -43200 to +50400 (-12h to +14h in seconds)
                    if intValue < -43200 || intValue > 50400 {
                        throw MacroError(text: "offsetSeconds must be between -43200 and 50400, got \(intValue)")
                    }
                }
            } else if memberName == "identifier" {
                if let firstArg = functionCall.arguments.first,
                   let stringValue = extractStringValue(from: firstArg.expression) {
                    if stringValue.isEmpty {
                        throw MacroError(text: "timezone identifier cannot be empty")
                    }
                }
            }
        }
    }
    
    /// Extract integer value from expression (handles positive and negative literals)
    private static func extractIntegerValue(from expr: ExprSyntax) -> Int? {
        // Handle positive integer literal
        if let intLiteral = expr.as(IntegerLiteralExprSyntax.self) {
            return Int(intLiteral.literal.text)
        }
        
        // Handle negative integer literal (prefix operator expression)
        if let prefixExpr = expr.as(PrefixOperatorExprSyntax.self),
           prefixExpr.operator.text == "-",
           let intLiteral = prefixExpr.expression.as(IntegerLiteralExprSyntax.self),
           let value = Int(intLiteral.literal.text) {
            return -value
        }
        
        return nil
    }
    
    /// Extract string value from expression
    private static func extractStringValue(from expr: ExprSyntax) -> String? {
        if let stringLiteral = expr.as(StringLiteralExprSyntax.self),
           let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
            return segment.content.text
        }
        return nil
    }
}
