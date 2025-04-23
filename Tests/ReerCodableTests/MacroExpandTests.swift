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
    "CodingContainer": CodingContainer.self,
    "DefaultInstance": DefaultInstance.self,
    "Copyable": Copyable.self,
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
            @Codable
            struct NetResponse<Element: Codable> {
                let data: Element?
                let msg: String
                private(set) var code: Int = 0
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
            enum Phone: Codable {
                @CodingCase(match: .bool(true), .int(8), .int(10), .intRange(12...22), .string("youtube"), .string("Apple"))
                case apple
                
                @CodingCase(match: .int(12), .string("MI"), .string("xiaomi"))
                case mi
                
                @CodingCase(match: .bool(false), .stringRange("o"..."q"))
                case oppo
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
    
    func testEnumPathValueMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable
            enum Video1: Codable {
                @CodingCase(match: .string("youtube", at: "type.middle"))
                case youTube
                
                @CodingCase(
                    match: .string("vimeo", at: "type"),
                    values: [.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
                )
                case vimeo(id: String, duration: TimeInterval = 33, Int)
                
                @CodingCase(
                    match: .intRange(20...25, at: "type"),
                    values: [.label("url", keys: "media")]
                )
                case tiktok(url: URL, tag: String?)
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

    func testExpand() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable
            @CodingContainer("data.info", workForEncoding: true)
            struct Person3 {
                var name: String
                var age: Int
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
