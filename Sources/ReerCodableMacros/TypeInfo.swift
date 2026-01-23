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

import SwiftSyntax
import SwiftSyntaxMacros

struct AssociatedValue {
    var label: String?
    var type: String
    var index: Int
    var defaultValue: String?
    
    var variableName: String {
        return label ?? "_\(index)"
    }
}

struct AssociatedMatch {
    let label: String?
    let keys: [String]
    let index: String?
}

struct PathValueMatch {
    let valueType: String
    let value: String
    let path: String
    
    var tupleString: String {
        return "(\(path), \(value), \(valueType).self)"
    }
}

struct EnumCase {
    var caseName: String
    var rawValue: String
    // [Type: Value]
    var matches: [String: [String]] = [:]
    var matchOrder: [String] = []
    var keyPathMatches: [PathValueMatch] = []
    var associatedMatch: [AssociatedMatch] = []
    var associated: [AssociatedValue] = []
    
    var initText: String {
        let associated = "\(associated.compactMap { "\($0.label == nil ? $0.variableName : "\($0.variableName): \($0.variableName)")" }.joined(separator: ","))"
        let postfix = associated.isEmpty ? "\(associated)" : "(\(associated))"
        return """
            .\(caseName)\(postfix)
            """
    }
}

struct TypeInfo {
    let decl: DeclGroupSyntax
    let name: String
    var isEnum = false
    var enumRawType: String?
    var enumCases: [EnumCase] = []
    var caseStyles: [CaseStyle] = []
    var properties: [PropertyInfo] = []
    var codingContainer: String?
    var codingContainerWorkForEncoding = false
    var isFlexibleType = false
    var isNSObjectSubclass = false
    
    init(decl: DeclGroupSyntax) throws {
        self.decl = decl
        
        if let structDecl = decl.as(StructDeclSyntax.self) {
            name = structDecl.name.trimmedDescription
        } else if let classDecl = decl.as(ClassDeclSyntax.self) {
            name = classDecl.name.trimmedDescription
        } else if let enumDecl = decl.as(EnumDeclSyntax.self) {
            name = enumDecl.name.trimmedDescription
        } else {
            throw MacroError(text: "Can not parse type name.")
        }
        
        if let enumDecl = decl.as(EnumDeclSyntax.self) {
            self.isEnum = true
            let availableRawTypes = [
                "Int", "Int8", "Int16", "Int32", "Int64", "Int128",
                "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "UInt128",
                "String", "Float", "Double"
            ]
            if let rawTypeName = enumDecl.inheritanceClause?.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self)?.name.trimmedDescription,
               availableRawTypes.contains(rawTypeName) {
                enumRawType = rawTypeName
            }
            
            var index = 0
            var lastIntRawValue: Int = 0
            try enumDecl.memberBlock.members.forEach {
                try $0.decl.as(EnumCaseDeclSyntax.self)?.elements.forEach { caseElement in
                    let name = caseElement.name.trimmedDescription
                    var raw: String
                    if let rawValueExpr = caseElement.rawValue?.value {
                        let rawValue = rawValueExpr.trimmedDescription
                        raw = rawValue
                        if let intRaw = rawValueExpr.as(IntegerLiteralExprSyntax.self) {
                            lastIntRawValue = Int(intRaw.trimmedDescription) ?? 0
                        }
                    } else if let enumRawType {
                        switch enumRawType {
                        case "Int", "Int8", "Int16", "Int32", "Int64", "Int128", "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "UInt128":
                            raw = if index == 0 { "0" } else { String(lastIntRawValue + 1) }
                            lastIntRawValue = Int(raw) ?? lastIntRawValue + 1
                        case "String":
                            raw = "\"\(name)\""
                        case "Double", "Float":
                            raw = if index == 0 { "0" } else { String(lastIntRawValue + 1) }
                            lastIntRawValue = Int(raw) ?? lastIntRawValue + 1
                        default:
                            throw MacroError(text: "Can not handle enum raw type: \(enumRawType)")
                        }
                    } else {
                        raw = "\"\(name)\""
                    }
                    var associated: [AssociatedValue] = []
                    var paramIndex = 0
                    caseElement.parameterClause?.parameters.forEach {
                        let label = $0.firstName?.trimmedDescription
                        let type = $0.type.trimmedDescription
                        let defaultValue = $0.defaultValue?.value.trimmedDescription
                        associated.append(.init(label: label, type: type, index: paramIndex, defaultValue: defaultValue))
                        paramIndex += 1
                    }
                    enumCases.append(.init(caseName: name, rawValue: raw, associated: associated))
                    index += 1
                }
                
                if let attribute = $0.decl.as(EnumCaseDeclSyntax.self)?.attributes.first?.as(AttributeSyntax.self),
                   attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.trimmedDescription == "CodingCase" {
                    if let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) {
                        arguments.forEach {
                            if ($0.label?.trimmedDescription == "match" || $0.label == nil),
                               let functionCall = $0.expression.as(FunctionCallExprSyntax.self) {
                                if let lastArg = functionCall.arguments.last,
                                   lastArg.label?.trimmedDescription == "at",
                                   let type = functionCall.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription.removingSuffix("Range").capitalized,
                                   let value = functionCall.arguments.first?.trimmedDescription.removingSuffix(",").trimmed {
                                    // key path value
                                    var last = enumCases.removeLast()
                                    last.keyPathMatches.append(
                                        .init(
                                            valueType: type,
                                            value: value,
                                            path: lastArg.expression.trimmedDescription
                                        )
                                    )
                                    enumCases.append(last)
                                } else if let tuple = parseEnumCaseMatchString(functionCall.trimmedDescription) {
                                    // normal
                                    var last = enumCases.removeLast()
                                    if last.matches[tuple.type] == nil {
                                        last.matchOrder.append(tuple.type)
                                    }
                                    var values = last.matches[tuple.type] ?? []
                                    values.append(tuple.value)
                                    last.matches[tuple.type] = values
                                    enumCases.append(last)
                                }
                            }
                            if $0.label?.trimmedDescription == "values",
                               let values = $0.expression.as(ArrayExprSyntax.self) {
                                let valueMatches = values.elements.compactMap { match in
                                    if let expression = match.expression.as(FunctionCallExprSyntax.self) {
                                        
                                        var label: String?
                                        var indexArg: String?
                                        var keys: [String] = []
                                        let labelOrIndex = expression.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription
                                        if labelOrIndex == "label" {
                                            for (idx, arg) in expression.arguments.enumerated() {
                                                if idx == 0 {
                                                    label = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription
                                                } else if let keyArg = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription {
                                                    keys.append(keyArg)
                                                }
                                            }
                                        } else if labelOrIndex == "index" {
                                            for (idx, arg) in expression.arguments.enumerated() {
                                                if idx == 0 {
                                                    indexArg = arg.expression.as(IntegerLiteralExprSyntax.self)?.trimmedDescription
                                                } else if let keyArg = arg.expression.as(StringLiteralExprSyntax.self)?.trimmedDescription {
                                                    keys.append(keyArg)
                                                }
                                            }
                                        }
                                        return AssociatedMatch(label: label, keys: keys, index: indexArg)
                                    } else {
                                        return nil
                                    }
                                }
                                var last = enumCases.removeLast()
                                last.associatedMatch = valueMatches
                                enumCases.append(last)
                            }
                        }
                    }
                }
            }
        }
        try validateEnumCases(enumCases)
        caseStyles = decl.attributes.compactMap {
            let attributeId = $0.as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .trimmedDescription
            if attributeId == "Codable" { return nil }
            for caseStyle in CaseStyle.allCases {
                if caseStyle.macroName == attributeId {
                    return caseStyle
                }
            }
            return nil
        }
        if let attribute = decl.attributes.firstAttribute(named: "CodingContainer"),
           let arguments = attribute.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self) {
            codingContainer = arguments
                .first?.expression.as(StringLiteralExprSyntax.self)?
                .segments.trimmedDescription
            if arguments.last?.label?.trimmedDescription == "workForEncoding",
               arguments.last?.expression.trimmedDescription == "true" {
                codingContainerWorkForEncoding = true
            }
        }
        if decl.attributes.containsAttribute(named: "FlexibleType") {
            isFlexibleType = true
        }
        #if AutoFlexibleType
        // When AutoFlexibleType trait is enabled, all types default to flexible type conversion
        isFlexibleType = true
        #endif
        // Check if the class inherits from NSObject
        if let classDecl = decl.as(ClassDeclSyntax.self),
           let inheritedTypes = classDecl.inheritanceClause?.inheritedTypes {
            isNSObjectSubclass = inheritedTypes.contains { $0.type.trimmedDescription == "NSObject" }
        }
        properties = try parseProperties()
    }
}

// MARK: - Parse info

extension TypeInfo {
    func parseProperties() throws -> [PropertyInfo] {
        return try decl.memberBlock.members.flatMap { member -> [PropertyInfo] in
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                variable.isStoredProperty
            else {
                return []
            }
            var properties: [PropertyInfo] = []
            for _ in variable.bindings {
                if variable.isLazy { continue }
                
                guard let type = variable.type else {
                    throw MacroError(text: "Unable to infer the property type. Specify the type explicitly.")
                }
                guard let name = variable.name else {
                    throw MacroError(text: "Macro expansion failed: property requires a name.")
                }
                
                var property = PropertyInfo(name: name, type: type)
                let attributeArgument: (String) -> String? = { attributeName in
                    guard
                        let attribute = variable.attributes.firstAttribute(named: attributeName)?
                            .as(AttributeSyntax.self),
                        let arguments = attribute.arguments?.as(LabeledExprListSyntax.self),
                        let expr = arguments.first?.expression
                    else { return nil }
                    return expr.trimmedDescription
                }
                // isOptional
                property.isOptional = variable.isOptional
                // get property case attributes
                let propertyCaseStyles = variable.attributes.compactMap {
                    let attributeId = $0.as(AttributeSyntax.self)?
                        .attributeName.as(IdentifierTypeSyntax.self)?
                        .trimmedDescription
                    for caseStyle in CaseStyle.allCases {
                        if caseStyle.macroName == attributeId {
                            return caseStyle
                        }
                    }
                    return nil
                }
                property.caseStyles = propertyCaseStyles.uniqueMerged(with: caseStyles)
                // ignore coding
                if variable.attributes.firstAttribute(named: "CodingIgnored") != nil {
                    property.isIgnored = true
                }
                // base64 coding
                if variable.attributes.containsAttribute(named: "Base64Coding") {
                    property.base64Coding = true
                }
                // date coding
                if let dateCoding = variable.attributes.firstAttribute(named: "DateCoding") {
                    property.dateCodingStrategy = dateCoding.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?.trimmedDescription
                }
                
                if variable.attributes.containsAttribute(named: "CompactDecoding") {
                    property.isCompactDecoding = true
                }
                
                // flat
                if variable.attributes.containsAttribute(named: "Flat") {
                    property.isFlat = true
                }

                if let customCoding = variable.attributes.firstAttribute(named: "CustomCoding"),
                   let attribute = customCoding.as(AttributeSyntax.self),
                   let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) {
                    property.customDecoder = arguments
                        .first(where: { $0.label?.identifier?.name == "decode" })?
                        .expression.trimmedDescription
                    
                    property.customEncoder = arguments
                        .first(where: { $0.label?.identifier?.name == "encode" })?
                        .expression.trimmedDescription
                    
                    if property.customDecoder == nil, property.customEncoder == nil {
                        property.customByType = arguments.trimmedDescription
                    }
                }
                // auto convert type or set nil for Optional
                property.isFlexibleType = isFlexibleType
                if variable.attributes.containsAttribute(named: "FlexibleType") {
                    property.isFlexibleType = true
                }
                
                // coding key
                if let codingKey = variable.attributes.firstAttribute(named: "CodingKey") {
                    property.keys = codingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .compactMap { $0.expression.trimmedDescription } ?? []
                }
                // encoding key
                if let encodingKey = variable.attributes.firstAttribute(named: "EncodingKey") {
                    property.encodingKey = encodingKey.as(AttributeSyntax.self)?
                        .arguments?.as(LabeledExprListSyntax.self)?
                        .first?.expression.trimmedDescription
                    
                    if let treatDotAsNested = encodingKey.as(AttributeSyntax.self)?
                           .arguments?.as(LabeledExprListSyntax.self)?
                           .first(where: { $0.label?.trimmedDescription == "treatDotAsNested" })?
                           .expression.trimmedDescription,
                       treatDotAsNested == "false" {
                        property.treatDotAsNestedWhenEncoding = false
                    }
                }
                
                property.initExpr = variable.initExpr
                
                let codingDefaultExpr = attributeArgument("CodingDefault")
                let decodingDefaultExpr = attributeArgument("DecodingDefault")
                let encodingDefaultExpr = attributeArgument("EncodingDefault")
                property.decodingDefaultValue = decodingDefaultExpr ?? codingDefaultExpr
                property.encodingDefaultValue = encodingDefaultExpr ?? codingDefaultExpr
                properties.append(property)
            }
            return properties
        }
    }
    // .int(8) -> (Int, "8")
    func parseEnumCaseMatchString(_ string: String) -> (type: String, value: String)? {
        let cleaned = string.trimmingCharacters(in: .whitespaces)
        
        guard
            let range = cleaned.range(of: "("),
            let endRange = cleaned.range(of: ")", options: .backwards)
        else {
            return nil
        }
        
        var typeStr = cleaned[cleaned.index(after: cleaned.startIndex)..<range.lowerBound]
            .trimmingCharacters(in: .whitespaces)
        let valueStr = cleaned[range.upperBound..<endRange.lowerBound]
            .trimmingCharacters(in: .whitespaces)
        
        typeStr = typeStr.prefix(1).uppercased() + typeStr.removingSuffix("Range").dropFirst()
        
        return (typeStr, valueStr)
    }
    /*
     @Codable
     enum Phone {
         @CodingCase(match: .bool(true), .int(8), .int(10), .string("youtube"), .string("Apple"))
         case apple
         
         @CodingCase(match: .int(12), .string("MI"), .string("xiaomi"))
         case mi
         case oppo
     }
     
     [
         "Int": [
             ("valueString": "8, 10", "caseName": "apple"),
             ("valueString": "12", "caseName": "mi")
         ],
         "String": [
             ("valueString": "apple", "caseName": "apple"),
             ("valueString": "MI, xiaomi", "caseName": "mi")
         ],
         "Bool": [
             ("valueString": "true", "caseName": "apple")
         ]
     ]
     */
    func processEnumCases(_ enumCases: [EnumCase]) -> [(type: String, values: [(valueString: String, caseName: String)])] {
        var result: [String: [(String, String)]] = [:]
        var typeOrder: [String] = []
        
        for enumCase in enumCases {
            let orderedTypes = enumCase.matchOrder.isEmpty
                ? Array(enumCase.matches.keys)
                : enumCase.matchOrder
            for type in orderedTypes {
                guard let values = enumCase.matches[type] else { continue }
                if result[type] == nil {
                    result[type] = []
                    typeOrder.append(type)
                }
                let caseInfo = (values.joined(separator: ", "), enumCase.caseName)
                result[type]?.append(caseInfo)
            }
        }
        
        return typeOrder.map { type in
            (type: type, values: result[type] ?? [])
        }
    }
    
    func validateEnumCases(_ cases: [EnumCase]) throws {
        var matchMap: [String: [String: String]] = [:]
        
        for enumCase in cases {
            let orderedTypes = enumCase.matchOrder.isEmpty
                ? Array(enumCase.matches.keys)
                : enumCase.matchOrder
            for type in orderedTypes {
                guard let values = enumCase.matches[type] else { continue }
                if matchMap[type] == nil {
                    matchMap[type] = [:]
                }
                
                for value in values {
                    if let existingCase = matchMap[type]?[value] {
                        let error = """
                            Duplicate match found: \(type.lowercased())(\(value)) is used in both cases '\(existingCase)' and '\(enumCase.caseName)'. Matching cases must be mutually exclusive.
                            """
                        throw MacroError(text: error)
                    }
                    matchMap[type]?[value] = enumCase.caseName
                }
            }
            
            try enumCase.associatedMatch.forEach {
                if let matchLabel = $0.label, !enumCase.associated.contains(where: {
                    guard let label = $0.label else { return false }
                    return "\"\(label)\"" == matchLabel
                }) {
                    throw MacroError(text: "Can not found an associated value named \(matchLabel) in case '\(enumCase.caseName)'.")
                }
                if let index = $0.index, let int = Int(index) {
                    if int >= enumCase.associated.count {
                        throw MacroError(text: "Can not found an associated value at index \(int) in case '\(enumCase.caseName)'.")
                    } else if let label = enumCase.associated[int].label {
                        var keysFromMatchLabel = enumCase.associatedMatch.first { $0.label == "\"\(label)\"" }?.keys ?? []
                        keysFromMatchLabel.append(contentsOf: $0.keys)
                        throw MacroError(text: "Associated value in case '\(enumCase.caseName)' at index \(int) has a label, use '.label(\"\(label)\", keys: \(keysFromMatchLabel.joined(separator: ", ")))' instead.")
                    }
                }
            }
            
            var usedLabels: Set<String> = []
            var usedIndices: Set<Int> = []
                
            for match in enumCase.associatedMatch {
                if let label = match.label {
                    if !usedLabels.insert(label).inserted {
                        throw MacroError(text: "Duplicate AssociatedValue label \(label) found in case '\(enumCase.caseName)'")
                    }
                }
                
                if let indexStr = match.index,
                   let index = Int(indexStr) {
                    if !usedIndices.insert(index).inserted {
                        throw MacroError(text: "Duplicate AssociatedValue index '\(index)' found in case '\(enumCase.caseName)'")
                    }
                }
            }
        }
        
        let flated = cases.flatMap { $0.matches }
        let hasPathValue = cases.contains { !$0.keyPathMatches.isEmpty }
        let hasOtherTypes = !flated.isEmpty
        if hasPathValue && hasOtherTypes {
            throw MacroError(text: "Invalid usage: CaseMatcher with key path cannot be used with other match patterns without key path like .string(), .int()...")
        }
        
        let hasAssociated = cases.contains { !$0.associated.isEmpty }
        let hasNonString = flated.contains { $0.key != "String" }
        if hasAssociated && hasNonString {
            throw MacroError(text: "Only CaseMatcher with key path and .string() patterns are allowed for enum cases with associated values")
        }
    }
}

// MARK: - Generate

extension TypeInfo {
    /// Decode
    func generateDecoderInit(isOverride: Bool = false) throws -> DeclSyntax {
        var shouldAddDidDecode = true
        var assignments: String
        if isEnum {
            let (code, addDidDecode) = generateEnumDecoderAssignments()
            assignments = code
            shouldAddDidDecode = addDidDecode
        } else {
            assignments = try properties
                .compactMap { property in
                    if property.isIgnored {
                        if property.isOptional { return nil }
                        if let initExpr = property.initExpr {
                            return "self.\(property.name) = \(initExpr)"
                        } else if let defaultValue = property.defaultValue {
                            return "self.\(property.name) = \(defaultValue)"
                        }
                        throw MacroError(text: "The ignored property '\(property.name)' should have a default value, or be set as an optional type.")
                    }
                    var body: String
                    // base64
                    if property.base64Coding {
                        let questionMark = property.isOptional ? "?" : ""
                        let uint8 = property.type.hasPrefix("[UInt8]") ? ".re_bytes" : ""
                        body = """
                            {
                                let base64String = try container.decode(type: String\(questionMark).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                                return try base64String\(questionMark).re_base64DecodedData\(uint8)
                            }()
                            """
                    }
                    // Date
                    else if let dateCodingStrategy = property.dateCodingStrategy {
                        body = """
                            container.decodeDate(
                                type: \(property.type).self, 
                                keys: [\(property.codingKeys.joined(separator: ", "))], 
                                strategy: \(dateCodingStrategy)
                            )
                            """
                    }
                    // compact decode
                    else if property.isCompactDecoding {
                        let propertyType = parseSwiftType(property.type)
                        if propertyType.isArray {
                            body = """
                                container.compactDecodeArray(type: \(property.type.nonOptionalType).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                                """
                        } else if propertyType.isDictionary {
                            body = """
                                container.compactDecodeDictionary(type: \(property.type.nonOptionalType).self, keys: [\(property.codingKeys.joined(separator: ", "))])
                                """
                        } else if propertyType.isSet {
                            body = """
                                {
                                    Set(try container.compactDecodeArray(type: [\(property.type.nonOptionalType.setElement)].self, keys: [\(property.codingKeys.joined(separator: ", "))]))
                                }()
                                """
                        } else {
                            throw MacroError(text: "Can not handle property '\(property.name)' with @CompactDecoding.")
                        }
                    }
                    // custom decode
                    else if let customDecoder = property.customDecoder {
                        body = """
                            \(customDecoder)(decoder)
                            """
                    }
                    // custom decode by type
                    else if let customByType = property.customByType {
                        body = """
                            \(customByType).decode(by: decoder, keys: [\(property.stringCodingKeys.joined(separator: ", "))])
                            """
                    }
                    // normal
                    else {
                        let useDefaultDecodeFunc =
                            !property.isOptional
                            && property.stringCodingKeys.count == 1
                            && !property.stringCodingKeys[0].hasDot
                            && !property.isFlexibleType
                        if property.isFlat {
                            let valueType = property.type.nonOptionalType
                            body = "\(valueType)(from: decoder)"
                        } else if useDefaultDecodeFunc {
                            body = """
                                container.decode(\(property.type).self, forKey: \(property.codingKeys[0]))
                                """
                        } else {
                            body = """
                                container.decode(type: \(property.type).self, keys: [\(property.codingKeys.joined(separator: ", "))], flexibleType: \(property.isFlexibleType))
                                """
                        }
                    }
                    
                    if let fallbackExpr = property.decodingFallbackExpr {
                        return "self.\(property.name) = (try? \(body)) ?? (\(fallbackExpr))"
                    } else if property.isOptional {
                        return "self.\(property.name) = try? \(body)"
                    } else {
                        return "self.\(property.name) = try \(body)"
                    }
                }
                .joined(separator: "\n")
        }
        
        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        var needRequired = isClass && !isFinal
        if isOverride {
            needRequired = true
        }
        let hasCodingNested = codingContainer != nil
        var container = isEnum && !hasEnumAssociatedValue
            ? "let container = try decoder.singleValueContainer()"
            : "\(hasCodingNested ? "var" : "let") container = try decoder.container(keyedBy: AnyCodingKey.self)"
        if let codingContainer {
            container.append(
                """
                
                container = try container.nestedContainer(keyPath: "\(codingContainer)")
                """
            )
        }
        // Determine if we need to call super.init()
        // - For NSObject subclass (not override): call super.init()
        // - For override (inherited from parent with Codable): call super.init(from: decoder)
        let superInitCall: String
        if isOverride {
            superInitCall = "\ntry super.init(from: decoder)"
        } else if isNSObjectSubclass {
            superInitCall = "\nsuper.init()"
        } else {
            superInitCall = ""
        }
        
        let decoder: DeclSyntax = """
        \(raw: needPublic ? "public " : "")\(raw: needRequired ? "required " : "")init(from decoder: any Decoder) throws {
            \(raw: container)
            \(raw: assignments)\(raw: superInitCall)
            \(raw: shouldAddDidDecode ? "try self.didDecode(from: decoder)" : "")
        }
        """
        return decoder
    }
    
    /// Encode
    func generateEncoderFunc(isOverride: Bool = false) throws -> DeclSyntax {
        var encoding: String
        if isEnum {
            encoding = generateEnumEncoderEncoding()
        } else {
            encoding = properties
                .compactMap { property in
                    if property.isIgnored { return nil }
                    let valueExpr = property.encodingValueExpr
                    let resolvedValueExpr = property.resolvedEncodingValueExpr
                    let needsOptionalHandling = property.needsOptionalEncodingHandling
                    let (encodingKey, treatDotAsNested) = if let specifiedEncodingKey = property.encodingKey {
                        (specifiedEncodingKey, property.treatDotAsNestedWhenEncoding)
                    } else {
                        (property.stringCodingKeys.first!, true)
                    }
                    // base64
                    if property.base64Coding {
                        let nonOptionalType = property.type.nonOptionalType
                        let dataExpr: String
                        if needsOptionalHandling {
                            dataExpr = nonOptionalType.hasPrefix("[UInt8]")
                                ? "\(resolvedValueExpr).map({ Data($0) })"
                                : resolvedValueExpr
                        } else {
                            dataExpr = nonOptionalType.hasPrefix("[UInt8]")
                                ? "Data(\(resolvedValueExpr))"
                                : resolvedValueExpr
                        }
                        return """
                        try {
                            let base64String = \(dataExpr)\(property.encodingQuestionMark).base64EncodedString()
                            try container.encode(value: base64String, key: AnyCodingKey(\(encodingKey), \(encodingKey.hasDot)), treatDotAsNested: \(treatDotAsNested))
                        }()
                        """
                    }
                    // Date
                    else if let dateCodingStrategy = property.dateCodingStrategy {
                        return """
                        try container.encodeDate(value: \(valueExpr), key: AnyCodingKey(\(encodingKey), \(encodingKey.hasDot)), treatDotAsNested: \(treatDotAsNested), strategy: \(dateCodingStrategy))
                        """
                    }
                    // custom encode
                    else if let customEncoder = property.customEncoder {
                        return """
                        let _ = try \(customEncoder)(encoder, \(valueExpr))
                        """
                    }
                    // custom encode by type
                    else if let customByType = property.customByType {
                        return """
                        try \(customByType).encode(by: encoder, key: \(encodingKey), value: \(valueExpr))
                        """
                    }
                    else if property.isFlat {
                        if needsOptionalHandling {
                            return "if let value = \(resolvedValueExpr) { try value.encode(to: encoder) }"
                        } else {
                            return "try \(resolvedValueExpr).encode(to: encoder)"
                        }
                    }
                    // normal
                    else {
                        return "try container.encode(value: \(valueExpr), key: AnyCodingKey(\(encodingKey), \(encodingKey.hasDot)), treatDotAsNested: \(treatDotAsNested))"
                    }
                }
                .joined(separator: "\n")
        }
        var container = isEnum && !hasEnumAssociatedValue
            ? "var container = encoder.singleValueContainer()"
            : "var container = encoder.container(keyedBy: AnyCodingKey.self)"
        if codingContainerWorkForEncoding, let codingContainer {
            container.append(
                """
                
                container = try container.nestedContainer(keyPath: "\(codingContainer)")
                """
            )
        }
        let accessable = if isOpen { "open " } else if isPublic || hasPublicOrOpenProperty { "public " } else { "" }
        let encoder: DeclSyntax = """
        \(raw: accessable)\(raw: isOverride ? "override " : "")func encode(to encoder: any Encoder) throws {
            try self.willEncode(to: encoder)
            \(raw: isOverride ? "try super.encode(to: encoder)\n" : "")\(raw: container)
            \(raw: encoding)
        }
        """
        return encoder
    }
    
    /// Init
    func generateMemberwiseInit(isOverride: Bool = false) throws -> DeclSyntax {
        let parameters = properties.map { property in
            var text = property.name
            text += ": \(property.type)"
            if let initExpr = property.initExpr {
                text += "= \(initExpr)"
            } else if property.isIgnored, let defaultValue = property.defaultValue {
                text += "= \(defaultValue)"
            } else if property.isOptional {
                text += "= nil"
            }
            return text
        }

        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        // For NSObject subclass or override, need to call super.init()
        let needSuperInit = isOverride || isNSObjectSubclass
        let superInitCall = needSuperInit ? "\nsuper.init()" : ""

        let initializer: DeclSyntax = """
        \(raw: needPublic ? "public " : "")init(\(raw: parameters.isEmpty ? "" : "\n")\(raw: parameters.joined(separator: ",\n"))\(raw: parameters.isEmpty ? "" : "\n")) {
            \(raw: properties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))\(raw: superInitCall)
        }
        """
        return initializer
    }
    
    func generateDefaultInstance() throws -> DeclSyntax {
        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        if isEnum, let firstCase = enumCases.first {
            let associated = firstCase.associated.map { associated in
                var text = ""
                if let label = associated.label {
                    text += "\(label): "
                }
                if let userDefineDefaultValue = associated.defaultValue {
                    text += userDefineDefaultValue
                } else if parseSwiftType(associated.type).isOptional {
                    text += "nil"
                } else if let typeDefaultValue = associated.type.nonOptionalType.typeDefaultValue {
                    text += typeDefaultValue
                } else {
                    text += "\(associated.type.nonOptionalType).default"
                }
                return text
            }
            let associatedString = firstCase.associated.isEmpty ? "" : "(\(associated.joined(separator: ", ")))"
            return """
            \(raw: needPublic ? "public " : "")static let `default` = \(raw: name).\(raw: firstCase.caseName)\(raw: associatedString)
            """ as DeclSyntax
        } else {
            let parameters = properties.map { property in
                var text = "\(property.name): "
                if let initExpr = property.initExpr {
                    text += "\(initExpr)"
                } else if property.isOptional {
                    text += "nil"
                } else if let defaultValue = property.defaultValue {
                    text += "\(defaultValue)"
                } else {
                    text += "\(property.type).default"
                }
                return text
            }
            
            return """
            \(raw: needPublic ? "public " : "")static let `default` = \(raw: name)(\(raw: parameters.isEmpty ? "" : "\n")\(raw: parameters.joined(separator: ",\n"))\(raw: parameters.isEmpty ? "" : "\n"))
            """ as DeclSyntax
        }
    }
    
    func generateCopy() throws -> DeclSyntax {
        let needPublic = hasPublicOrOpenProperty || isPublic || isOpen
        if isEnum {
            return """
            \(raw: needPublic ? "public " : "")func copy() -> \(raw: name) { self }
            """ as DeclSyntax
        } else {
            let parameters = properties.map { property in
                var text = property.name
                text += ": \(property.isOptional ? property.type : "\(property.type)?")"
                text += "= nil"
                return text
            }
            let arguments = properties.map { property in
                return "\(property.name): \(property.name) ?? self.\(property.name)"
            }
            return """
            \(raw: needPublic ? "public " : "")func copy(\(raw: parameters.isEmpty ? "" : "\n")\(raw: parameters.joined(separator: ",\n"))\(raw: parameters.isEmpty ? "" : "\n")) -> \(raw: name) {
                return .init(\(raw: arguments.isEmpty ? "" : "\n")\(raw: arguments.joined(separator: ",\n"))\(raw: arguments.isEmpty ? "" : "\n"))
            }
            """ as DeclSyntax
        }
    }
    
    /// Return: (assignments, shouldAddDidDecode)
    private func generateEnumDecoderAssignments() -> (String, Bool) {
        if hasEnumAssociatedValue {
            let hasPathValue = enumCases.contains { !$0.keyPathMatches.isEmpty }
            var index = -1
            let findCase = enumCases.compactMap { theCase in
                index += 1
                let hasAssociated = !theCase.associated.isEmpty
                var condition: String
                if hasPathValue {
                    let keyPathValues = theCase.keyPathMatches
                    condition = """
                        container.match(keyPathValues: [\(keyPathValues.map({ $0.tupleString }).joined(separator: ", "))])
                        """
                } else {
                    var keys = theCase.matches["String"] ?? []
                    keys.append("\"\(theCase.caseName)\"")
                    keys.removeDuplicates()
                    condition = """
                        let \(hasAssociated ? "nestedContainer" : "_") = try? container.nestedContainer(forKeys: \(keys.joined(separator: ", ")))
                        """
                }
                
                return """
                    \(index > 0 ? "else " : "")if \(condition) {
                        \(theCase.associated.compactMap { value in
                        var keys: [String] = []
                        if let label = value.label {
                            keys = theCase.associatedMatch.first { $0.label == "\"\(label)\"" }?.keys ?? []
                        } else {
                            keys = theCase.associatedMatch.first { $0.index == "\(value.index)" }?.keys ?? []
                        }
                        keys.append("\"\(value.variableName)\"")
                        keys.removeDuplicates()
                        let hasDefault = value.defaultValue != nil
                        return """
                        let \(value.variableName) = (try\(hasDefault ? "?" : "") \(hasPathValue ? "container" : "nestedContainer").decode(type: \(value.type).self, keys: [\(keys.map { "AnyCodingKey(\($0), \($0.hasDot))" }.joined(separator: ", "))]))\(hasDefault ? " ?? (\(value.defaultValue!))" : "")
                        """
                        }.joined(separator: "\n    "))
                        self = \(theCase.initText)
                    } 
                    """
            }.joined(separator: "\n")
            
            return (
                """
                \(hasPathValue ? "" : "guard container.allKeys.count == 1 else { throw ReerCodableError(text: \"Invalid number of keys found, expected one.\") }")
                \(findCase)
                else {
                    throw ReerCodableError(text: "Key not found for \\(String(describing: Self.self)).")
                }
                """, true)
        } else {
            if enumCases.contains(where: { !$0.matches.isEmpty }) {
                let matches = processEnumCases(enumCases)
                var orderedMatches = matches.filter { $0.type != "String" }
                if let stringMatch = matches.first(where: { $0.type == "String" }) {
                    orderedMatches.append(stringMatch)
                }
                let tryDecode = orderedMatches.compactMap { match -> String? in
                    guard !match.values.isEmpty else { return nil }
                    let type = match.type
                    let associatedValues = match.values
                    return """
                        if let value = try? container.decode(\(type).self) {\nswitch value {
                        \(associatedValues.compactMap {
                        """
                        case \($0.valueString): self = .\($0.caseName); try self.didDecode(from: decoder); return;
                        """
                        }.joined(separator: "\n"))
                        default: break
                        }
                        }
                        """
                }
                let tryRaw = """
                    let value = try container.decode(type: \(enumRawType ?? "String").self, enumName: String(describing: Self.self))
                    switch value {
                    \(enumCases.compactMap { "case \($0.rawValue): self = .\($0.caseName)" }.joined(separator: "\n"))
                    default: throw ReerCodableError(text: "Cannot initialize \\(String(describing: Self.self)) from invalid value \\(value)")
                    }
                    try self.didDecode(from: decoder)
                    """
                return (tryDecode.joined(separator: "\n") + "\n" + tryRaw, false)
            } else {
                return (
                    """
                    let value = try container.decode(type: \(enumRawType ?? "String").self, enumName: String(describing: Self.self))
                    switch value {
                    \(enumCases.compactMap { "case \($0.rawValue): self = .\($0.caseName)" }.joined(separator: "\n"))
                    default: throw ReerCodableError(text: "Cannot initialize \\(String(describing: Self.self)) from invalid value \\(value)")
                    }
                    """, true)
            }
        }
    }
    
    private func generateEnumEncoderEncoding() -> String {
        if hasEnumAssociatedValue {
            let hasPathValue = enumCases.contains { !$0.keyPathMatches.isEmpty }
            let encodeCase = """
                \(enumCases.compactMap {
                    let associated = "\($0.associated.compactMap { value in value.variableName }.joined(separator: ","))"
                    let postfix = $0.associated.isEmpty ? "\(associated)" : "(\(associated))"
                    let hasAssociated = !$0.associated.isEmpty
                    let encodeCase = if hasPathValue {
                        """
                        try container.encode(keyPath: AnyCodingKey(\($0.keyPathMatches.first!.path), \($0.keyPathMatches.first!.path.hasDot)), value: "\($0.caseName)")
                        """
                        }
                        else {
                        """
                        var nestedContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("\($0.caseName)"))
                        """
                        }
                    return """
                    case\(hasAssociated ? " let" : "") .\($0.caseName)\(postfix):
                        \(encodeCase)
                        \($0.associated.compactMap { value in
                        """
                        try \(hasPathValue ? "container" : "nestedContainer").encode(\(value.variableName), forKey: AnyCodingKey("\(value.variableName)"))
                        """
                        }.joined(separator: "\n    "))
                    """
                }.joined(separator: "\n"))
                """
            return """
                switch self {
                \(encodeCase)
                }
                """
        } else {
            return """
                switch self {
                \(enumCases.compactMap { "case .\($0.caseName): try container.encode(\($0.rawValue))" }.joined(separator: "\n"))
                }
                """
        }
    }
}

// MARK: - Info

extension TypeInfo {
    
    var isClass: Bool {
        return decl.is(ClassDeclSyntax.self)
    }
    
    var isFinal: Bool {
        guard let classDecl = decl.as(ClassDeclSyntax.self) else { return false }
        return classDecl.modifiers.contains { $0.name.text == "final" }
    }
    
    var isPublic: Bool {
        let modifiers = decl.modifiers.compactMap { $0.name.text }
        return modifiers.contains("public")
    }
    
    var isOpen: Bool {
        let modifiers = decl.modifiers.compactMap { $0.name.text }
        return modifiers.contains("open")
    }
    
    var hasPublicOrOpenProperty: Bool {
        return properties.contains { property in
            property.modifiers.contains { $0.name.text == "public" || $0.name.text == "open" }
        }
    }
    
    var hasEnumAssociatedValue: Bool {
        return isEnum && enumCases.contains { !$0.associated.isEmpty }
    }
}

extension Array where Element: Hashable {
    mutating func removeDuplicates() {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}

extension String {
    func removingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var hasDot: Bool {
        return contains(".")
    }
}
