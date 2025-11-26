import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ReerCodable
import MacroTesting
import Testing
import Foundation

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ReerCodableMacros)
import ReerCodableMacros
#endif

final class ReerCodableTests: XCTestCase {

    #if canImport(ReerCodableMacros)
    override func invokeTest() {
        withMacroTesting(
            indentationWidth: .spaces(4),
            record: .missing,
            macros: [
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
                "FlexibleType": FlexibleType.self,
            ]
        ) {
            super.invokeTest()
        }
    }
    #endif

    func testInheritedCodable() throws {
        #if canImport(ReerCodableMacros)
        assertMacro {
            """
            @Codable
            struct NetResponse<Element: Codable> {
                let data: Element?
                let msg: String
                private(set) var code: Int = 0
            }
            """
        } expansion: {
            """
            struct NetResponse<Element: Codable> {
                let data: Element?
                let msg: String
                private(set) var code: Int = 0

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: AnyCodingKey.self)
                    self.data = try? container.decode(type: Element?.self, keys: [AnyCodingKey("data", false)], flexibleType: false)
                    self.msg = try container.decode(String.self, forKey: AnyCodingKey("msg", false))
                    self.code = (try? container.decode(Int.self, forKey: AnyCodingKey("code", false))) ?? (0)
                    try self.didDecode(from: decoder)
                }

                func encode(to encoder: any Encoder) throws {
                    try self.willEncode(to: encoder)
                    var container = encoder.container(keyedBy: AnyCodingKey.self)
                    try container.encode(value: self.data, key: AnyCodingKey("data", false), treatDotAsNested: true)
                    try container.encode(value: self.msg, key: AnyCodingKey("msg", false), treatDotAsNested: true)
                    try container.encode(value: self.code, key: AnyCodingKey("code", false), treatDotAsNested: true)
                }

                init(
                    data: Element? = nil,
                    msg: String,
                    code: Int = 0
                ) {
                    self.data = data
                    self.msg = msg
                    self.code = code
                }
            }

            extension NetResponse: Codable, ReerCodableDelegate {
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testEnumMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacro {
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
            """
        } expansion: {
            #"""
            enum Phone: Codable {
                case apple

                case mi

                case oppo

                init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let value = try? container.decode(Bool.self) {
                        switch value {
                        case true:
                            self = .apple;
                            try self.didDecode(from: decoder);
                            return;
                        case false:
                            self = .oppo;
                            try self.didDecode(from: decoder);
                            return;
                        default:
                            break
                        }
                    }
                    if let value = try? container.decode(Int.self) {
                        switch value {
                        case 8, 10, 12 ... 22:
                            self = .apple;
                            try self.didDecode(from: decoder);
                            return;
                        case 12:
                            self = .mi;
                            try self.didDecode(from: decoder);
                            return;
                        default:
                            break
                        }
                    }
                    if let value = try? container.decode(String.self) {
                        switch value {
                        case "youtube", "Apple":
                            self = .apple;
                            try self.didDecode(from: decoder);
                            return;
                        case "MI", "xiaomi":
                            self = .mi;
                            try self.didDecode(from: decoder);
                            return;
                        case "o" ... "q":
                            self = .oppo;
                            try self.didDecode(from: decoder);
                            return;
                        default:
                            break
                        }
                    }
                    let value = try container.decode(type: String.self, enumName: String(describing: Self.self))
                    switch value {
                    case "apple":
                        self = .apple
                    case "mi":
                        self = .mi
                    case "oppo":
                        self = .oppo
                    default:
                        throw ReerCodableError(text: "Cannot initialize \(String(describing: Self.self)) from invalid value \(value)")
                    }
                    try self.didDecode(from: decoder)

                }

                func encode(to encoder: any Encoder) throws {
                    try self.willEncode(to: encoder)
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .apple:
                        try container.encode("apple")
                    case .mi:
                        try container.encode("mi")
                    case .oppo:
                        try container.encode("oppo")
                    }
                }
            }

            extension Phone: ReerCodableDelegate {
            }
            """#
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testEnumPathValueMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacro {
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
            """
        } expansion: {
            #"""
            enum Video1: Codable {
                case youTube

                case vimeo(id: String, duration: TimeInterval = 33, Int)

                case tiktok(url: URL, tag: String?)

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: AnyCodingKey.self)

                    if container.match(keyPathValues: [("type.middle", "youtube", String.self)]) {

                        self = .youTube
                    }
                    else if container.match(keyPathValues: [("type", "vimeo", String.self)]) {
                        let id = (try container.decode(type: String.self, keys: [AnyCodingKey("ID", false), AnyCodingKey("Id", false), AnyCodingKey("id", false)]))
                        let duration = (try? container.decode(type: TimeInterval.self, keys: [AnyCodingKey("duration", false)])) ?? (33)
                        let _2 = (try container.decode(type: Int.self, keys: [AnyCodingKey("minutes", false), AnyCodingKey("_2", false)]))
                        self = .vimeo(id: id, duration: duration, _2)
                    }
                    else if container.match(keyPathValues: [("type", 20 ... 25, Int.self)]) {
                        let url = (try container.decode(type: URL.self, keys: [AnyCodingKey("media", false), AnyCodingKey("url", false)]))
                        let tag = (try container.decode(type: String?.self, keys: [AnyCodingKey("tag", false)]))
                        self = .tiktok(url: url, tag: tag)
                    }
                    else {
                        throw ReerCodableError(text: "Key not found for \(String(describing: Self.self)).")
                    }
                    try self.didDecode(from: decoder)
                }

                func encode(to encoder: any Encoder) throws {
                    try self.willEncode(to: encoder)
                    var container = encoder.container(keyedBy: AnyCodingKey.self)
                    switch self {
                    case .youTube:
                        try container.encode(keyPath: AnyCodingKey("type.middle", true), value: "youTube")

                    case let .vimeo(id, duration, _2):
                        try container.encode(keyPath: AnyCodingKey("type", false), value: "vimeo")
                        try container.encode(id, forKey: AnyCodingKey("id"))
                        try container.encode(duration, forKey: AnyCodingKey("duration"))
                        try container.encode(_2, forKey: AnyCodingKey("_2"))
                    case let .tiktok(url, tag):
                        try container.encode(keyPath: AnyCodingKey("type", false), value: "tiktok")
                        try container.encode(url, forKey: AnyCodingKey("url"))
                        try container.encode(tag, forKey: AnyCodingKey("tag"))
                    }
                }
            }

            extension Video1: ReerCodableDelegate {
            }
            """#
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    static let test = "abc"
    func testMacro() throws {
        #if canImport(ReerCodableMacros)
        assertMacro {
            """
            @Codable
            @ScreamingKebabCase
            @Copyable
            @FlexibleType
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
            
            """
        } expansion: {
            """
            public final class Test {
                var userAge: Int = 18
                var name: String
                let height: Float?
                var set: Set<Int>
                var ignore: [Int]
                var date: Date?
                var array: [String]
                var custom: Int
                var customBy: Int

                public init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: AnyCodingKey.self)
                    self.userAge = (try? container.decode(type: Int.self, keys: [AnyCodingKey("age__", false), AnyCodingKey("a.b", true), AnyCodingKey("USER-AGE", false)], flexibleType: true)) ?? (18)
                    self.name = try container.decode(type: String.self, keys: [AnyCodingKey("NAME", false)], flexibleType: true)
                    self.height = try? container.decode(type: Float?.self, keys: [AnyCodingKey("HEIGHT", false)], flexibleType: true)
                    self.set = .init()
                    self.ignore = .init()
                    self.date = try? container.decodeDate(
                        type: Date?.self,
                        keys: [AnyCodingKey("DATE", false)],
                        strategy: .secondsSince1970
                    )
                    self.array = try container.compactDecodeArray(type: [String].self, keys: [AnyCodingKey("array.xxx", true), AnyCodingKey("ARRAY", false)])
                    self.custom = try { decoder in
                                return 222222
                            }(decoder)
                    self.customBy = try IntTransformer.self.decode(by: decoder, keys: ["CUSTOM-BY"])
                    try self.didDecode(from: decoder)
                }

                public func encode(to encoder: any Encoder) throws {
                    try self.willEncode(to: encoder)
                    var container = encoder.container(keyedBy: AnyCodingKey.self)
                    try container.encode(value: self.userAge, key: AnyCodingKey("a.b", true), treatDotAsNested: false)
                    try container.encode(value: self.name, key: AnyCodingKey("NAME", false), treatDotAsNested: true)
                    try container.encode(value: self.height, key: AnyCodingKey("HEIGHT", false), treatDotAsNested: true)
                    try container.encodeDate(value: self.date, key: AnyCodingKey("DATE", false), treatDotAsNested: true, strategy: .secondsSince1970)
                    try container.encode(value: self.array, key: AnyCodingKey("array.xxx", true), treatDotAsNested: true)
                    let _ = try { encoder, value  in
                                print(333333)
                            }(encoder, self.custom)
                    try IntTransformer.self.encode(by: encoder, key: "CUSTOM-BY", value: self.customBy)
                }

                public init(
                    userAge: Int = 18,
                    name: String,
                    height: Float? = nil,
                    set: Set<Int> = .init(),
                    ignore: [Int] = .init(),
                    date: Date? = nil,
                    array: [String],
                    custom: Int,
                    customBy: Int
                ) {
                    self.userAge = userAge
                    self.name = name
                    self.height = height
                    self.set = set
                    self.ignore = ignore
                    self.date = date
                    self.array = array
                    self.custom = custom
                    self.customBy = customBy
                }

                public func copy(
                    userAge: Int? = nil,
                    name: String? = nil,
                    height: Float? = nil,
                    set: Set<Int>? = nil,
                    ignore: [Int]? = nil,
                    date: Date? = nil,
                    array: [String]? = nil,
                    custom: Int? = nil,
                    customBy: Int? = nil
                ) -> Test {
                    return .init(
                        userAge: userAge ?? self.userAge,
                        name: name ?? self.name,
                        height: height ?? self.height,
                        set: set ?? self.set,
                        ignore: ignore ?? self.ignore,
                        date: date ?? self.date,
                        array: array ?? self.array,
                        custom: custom ?? self.custom,
                        customBy: customBy ?? self.customBy
                    )
                }
            }

            extension Test: Codable, ReerCodableDelegate {
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpand() throws {
        #if canImport(ReerCodableMacros)
        assertMacro {
            """
            @Codable
            struct HundredMeterRace {
               
                @CustomCoding(RankTransformer.self)
                @CodingKey("race_rank")
                @CodingIgnored
                @Base64Coding
                var rank: UInt
                
                @CustomCoding(RankTransformer.self)
                @KebabCase
                var testCase: UInt
            }
            """
        } diagnostics: {
            """
            @Codable
            struct HundredMeterRace {
               
                @CustomCoding(RankTransformer.self)
                ┬──────────────────────────────────
                ╰─ 🛑 @CustomCoding macro cannot be used together with @CodingIgnored, @Base64Coding.
                @CodingKey("race_rank")
                @CodingIgnored
                @Base64Coding
                ┬────────────
                ╰─ 🛑 @Base64Coding macro is only for `Data` or `[UInt8]`.
                var rank: UInt
                
                @CustomCoding(RankTransformer.self)
                @KebabCase
                var testCase: UInt
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
