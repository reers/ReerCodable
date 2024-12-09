import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ReerCodable
import Testing
import Foundation

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ReerCodableMacros)
import ReerCodableMacros

let testMacros: [String: Macro.Type] = [
    "Codable": RECodable.self,
    "InheritedCodable": InheritedCodable.self,
    "CodingKey": CodingKey.self,
    "EncodingKey": EncodingKey.self,
    "CodingIgnored": CodingIgnored.self,
    "Base64Coding": Base64Coding.self,
    "DateCoding": DateCoding.self,
    "CompactDecoding": CompactDecoding.self,
    "CustomCoding": CustomCoding.self,
    "CodingCase": CodingCase.self,
    "FlatCase": FlatCase.self,
    "UpperCase": UpperCase.self,
    "CamelCase": CamelCase.self,
    "PascalCase": PascalCase.self,
    "SnakeCase": SnakeCase.self,
    "KebabCase": KebabCase.self,
    "CamelSnakeCase": CamelSnakeCase.self,
    "PascalSnakeCase": PascalSnakeCase.self,
    "ScreamingSnakeCase": ScreamingSnakeCase.self,
    "CamelKebabCase": CamelKebabCase.self,
    "PascalKebabCase": PascalKebabCase.self,
    "ScreamingKebabCase": ScreamingKebabCase.self,
]
#endif

final class ReerCodableTests: XCTestCase {
    
    func testInheritedCodable() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @InheritedCodable
            class LLLA: Equatable {
                
            }
            """,
            expandedSource: """
            
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testEnumMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable
            enum Video3: Codable {
                @CodingCase(match: .nested("type.middle.youtube"))
                case youTube
                
                @CodingCase(
                    match: .nested("type.vimeo"),
                    values: [CaseValue(label: "id", keys: "ID", "Id"), .init(index: 2, keys: "minutes")]
                )
                case vimeo(id: String, duration: TimeInterval = 33, Int)
                
                @CodingCase(
                    match: .nested("type.hosted"),
                    values: [.init(label: "url", keys: "url")]
                )
                case hosted(url: URL, tag: String?)
            }
            """,
            expandedSource: """
            
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    static let test = "abc"
    func testMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable
            @ScreamingKebabCase
            public final class Test {
                @CodingKey("age__", "a.b")
                @EncodingKey("a.b", treatDotAsNested: false)
                var userAge: Int = 18
                var name: String
                let height: Float?
                @CodingIgnored
                var set: Set<Int>

                @CodingIgnored
                var ignore: [Int]
            
                @DateCoding(.secondsSince1970)
                var date: Date?
            
                @CodingKey("array.xxx")
                @CompactDecoding
                var array: [String]
            
                @CustomCoding<Int>(
                    decode: { decoder in
                        return 222222
                    },
                    encode: { encoder, value  in
                        print(333333)
                    }
                )
                var custom: Int
            
                @CustomCoding(IntTransformer.self)
                var customBy: Int
            }

            """,
            expandedSource: """
            struct Test {}
            
            extension Test: Codable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    
}
