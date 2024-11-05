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
]
#endif

final class ReerCodableTests: XCTestCase {
    
    static let test = "abc"
    func testMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacroExpansion(
            """
            @Codable(memberwiseInit: false)
            public struct Test {
                fileprivate var name = ["1", ""] {
                    didSet {
                        print("newValue")
                    }
                }
                var age: Int
                var height: Float
                
                public init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: AnyCodingKey.self)
                        self.name = try container.decode(type: String?.self, keys: ["name"])
                }
                public func encode(to encoder: any Encoder) throws {
                    
                }
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
