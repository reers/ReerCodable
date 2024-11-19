import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ReerCodableMacros)
import ReerCodableMacros

let testMacros: [String: Macro.Type] = [
    "Codable": Codable.self,
    "CodableSubclass": CodableSubclass.self,
    "CodingKey": CodingKey.self,
    "EncodingKey": EncodingKey.self,
    "IgnoreCoding": IgnoreCoding.self,
    "Base64Coding": Base64Coding.self,
    "DateCoding": DateCoding.self,
    "CompactDecoding": CompactDecoding.self,
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
                @IgnoreCoding
                var set: Set<Int>

                @IgnoreCoding
                var ignore: [Int]
            
                @DateCoding(.secondsSince1970)
                var date: Date?
            
                @CodingKey("array.xxx")
                @CompactDecoding
                var array: [String]
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
