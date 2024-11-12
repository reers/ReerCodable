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
    "IgnoreCoding": IgnoreCoding.self
]
#endif

final class ReerCodableTests: XCTestCase {
    
    static let test = "abc"
    func testMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable
            public final class Test: CodableDelegate {
                public func didDecodeModel() {
                    
                }
                
                public func willEncodeModel() {
                    
                }
                
                @CodingKey("a.b")
                @EncodingKey("abccccc.sssss", treatDotAsNested: false)
                var age: Int = 18
                var name: String
                let height: Float?
                
                @IgnoreCoding
                var ignore: [String: Int]?
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
