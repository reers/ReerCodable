import XCTest
@testable import ReerCodable
import Testing
import Foundation

@Codable
struct User {
    let gender: Gender
    let rawInt: RawInt
    let rawDouble: RawDouble
    let rawDouble2: RawDouble2
    let rawString: RawString
}

@Codable
enum Gender {
    case male, female
}

@Codable
enum RawInt: Int {
    case one = 1, two, three, other = 100
}

@Codable
enum RawDouble: Double {
    case one, two, three, other = 100.0
}

@Codable
enum RawDouble2: Double {
    case one = 1.1, two = 2.2, three = 3.3, other = 4.4
}

@Codable
enum RawString: String {
    case one, two, three, other = "helloworld"
}

let enumJSONData1 = """
{
    "gender": "female",
    "rawInt": 3,
    "rawDouble": 100.0,
    "rawDouble2": 2.2,
    "rawString": "helloworld"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func enum1() throws {
        // Decode
        let model = try JSONDecoder().decode(User.self, from: enumJSONData1)
        #expect(model.gender == .female)
        #expect(model.rawInt == .three)
        #expect(model.rawDouble == .other)
        #expect(model.rawDouble2 == .two)
        #expect(model.rawString == .other)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("gender") == "female")
        #expect(dict.int("rawInt") == 3)
        #expect(dict.double("rawDouble") == 100)
        #expect(dict.double("rawDouble2") == 2.2)
        #expect(dict.string("rawString") == "helloworld")
    }
}



@Codable
enum Phone: Codable {
    @CodingCase(match: .bool(true), .int(8), .int(10), .string("iphone"), .string("Apple"), .intRange(22...30))
    case iPhone
    
    @CodingCase(match: .int(12), .string("MI"), .double(22.5), .string("xiaomi"), .doubleRange(50...60))
    case xiaomi
    
    @CodingCase(match: .bool(false), .string("oppo"), .stringRange("o"..."q"))
    case oppo
}

@Codable
enum ExplicitMatch: Codable {
    @CodingCase(match: .string("Test"))
    case test
}

struct UserExplicit: Codable {
    let value: ExplicitMatch
}

struct User2: Codable {
    let phone: Phone
}

extension TestReerCodable {
    @Test(
        arguments: [
            "{\"phone\": true}",
            "{\"phone\": 8}",
            "{\"phone\": 10}",
            "{\"phone\": \"iphone\"}",
            "{\"phone\": \"Apple\"}",
            "{\"phone\": 25}",
        ]
    )
    func enumiPhone(jsonString: String) throws {
        // Decode
        let model = try User2.decoded(from: jsonString.data(using: .utf8)!)
        #expect(model.phone == .iPhone)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.bool("phone") == true)
    }
    
    @Test(
        arguments: [
            "{\"phone\": 12}",
            "{\"phone\": 22.5}",
            "{\"phone\": \"MI\"}",
            "{\"phone\": \"xiaomi\"}",
            "{\"phone\": 55.5}"
        ]
    )
    func enumMI(jsonString: String) throws {
        // Decode
        let model = try User2.decoded(from: jsonString.data(using: .utf8)!)
        #expect(model.phone == .xiaomi)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.int("phone") == 12)
    }
    
    @Test(
        arguments: [
            "{\"phone\": false}",
            "{\"phone\": \"oppo\"}",
            "{\"phone\": \"p\"}",
        ]
    )
    func enumOppo(jsonString: String) throws {
        // Decode
        let model = try User2.decoded(from: jsonString.data(using: .utf8)!)
        #expect(model.phone == .oppo)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.bool("phone") == false)
    }
}

extension TestReerCodable {
    @Test
    func enumExplicitMatch() throws {
        let json = "{\"value\": \"Test\"}"
        let model = try UserExplicit.decoded(from: json.data(using: .utf8)!)
        #expect(model.value == .test)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        #expect(dict.string("value") == "Test")
        
        let invalid = try? UserExplicit.decoded(from: "{\"value\": \"test\"}".data(using: .utf8)!)
        #expect(invalid == nil)
    }
}



@Codable
enum Video: Codable {
    @CodingCase(match: .string("youtube"), .string("YOUTUBE"))
    case youTube
    
    @CodingCase(
        match: .string("vimeo"),
        values: [AssociatedValue.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
    )
    case vimeo(id: String, duration: TimeInterval = 33, Int)
    
    @CodingCase(
        match: .string("tiktok"),
        values: [.label("url", keys: "url")]
    )
    case tiktok(url: URL, tag: String?)
}

extension TestReerCodable {
    @Test(arguments: [
        """
        {
            "youtube": {
                "id": "ujOc3a7Hav0",
                "_1": 44.5
            }
        }
        """,
        """
        {
            "YOUTUBE": {
                "id": "ujOc3a7Hav0",
                "_1": 44.5
            }
        }
        """,
        """
        {
            "vimeo": {
                "ID": "234961067",
                "minutes": 999999
            }
        }
        """,
        """
        {
            "tiktok": {
                "url": "https://example.com/video.mp4",
                "tag": "Art"
            }
        }
        """
    ])
    func eunmWithAssociated(json: String) throws {
        let model = try Video.decoded(from: json.data(using: .utf8)!)
        
        switch model {
        case .youTube:
            if json.lowercased().contains("youtube") {
                #expect(true)
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let index = modelData.stringAnyDictionary?.index(forKey: "youtube")
                #expect(index != nil)
            } else {
                Issue.record("Expected youtube")
            }
        case .vimeo(id: let id, duration: let duration, let minutes):
            if json.lowercased().contains("vimeo"),
               id == "234961067",
               duration == 33,
               minutes == 999999 {
                #expect(true)
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary?["vimeo"] as? [String: Any]
                #expect(dict != nil)
                #expect(dict.string("id") == "234961067")
                #expect(dict.int("_2") == 999999)
                #expect(dict.int("duration") == 33)
            } else {
                Issue.record("Expected vimeo")
            }
        case .tiktok(url: let url, tag: let tag):
            if json.lowercased().contains("tiktok"),
               url.absoluteString == "https://example.com/video.mp4",
               tag == "Art" {
                #expect(true)
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary?["tiktok"] as? [String: Any]
                #expect(dict != nil)
                #expect(dict.string("url") == "https://example.com/video.mp4")
                #expect(dict.string("tag") == "Art")
            } else {
                Issue.record("Expected tiktok")
            }
        }
    }
}



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
        match: .string("tiktok", at: "type"),
        values: [.label("url", keys: "media")]
    )
    case tiktok(url: URL, tag: String?)
}

extension TestReerCodable {
    @Test(arguments: [
        """
        {
            "type": {
                "middle": "youtube"
            }
        }
        """,
        """
        {
            "type": "vimeo",
            "ID": "234961067",
            "minutes": 999999
        }
        """,
        """
        {
            "type": "tiktok",
            "media": "https://example.com/video.mp4",
            "tag": "Art"
        }
        """
    ])
    func eunmWithAssociated1(json: String) throws {
        let model = try Video1.decoded(from: json.data(using: .utf8)!)
        
        switch model {
        case .youTube:
            if json.lowercased().contains("youtube") {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary?["type"] as? [String: Any]
                #expect(dict.string("middle") == "youtube")
            } else {
                Issue.record("Expected youtube")
            }
        case .vimeo(id: let id, duration: let duration, let minutes):
            if json.lowercased().contains("vimeo"),
               id == "234961067",
               duration == 33,
               minutes == 999999 {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary
                #expect(dict.string("type") == "vimeo")
                #expect(dict.double("duration") == 33)
                #expect(dict.string("id") == "234961067")
                #expect(dict.int("_2") == 999999)
            } else {
                Issue.record("Expected vimeo")
            }
        case .tiktok(url: let url, tag: let tag):
            if json.lowercased().contains("tiktok"),
               url.absoluteString == "https://example.com/video.mp4",
               tag == "Art" {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary
                #expect(dict.string("type") == "tiktok")
                #expect(dict.string("url") == "https://example.com/video.mp4")
                #expect(dict.string("tag") == "Art")
            } else {
                Issue.record("Expected tiktok")
            }
        }
    }
}


@Codable
enum Video5: Codable {
    @CodingCase(match: .string("youtube", at: "type.middle"))
    case youTube
    
    @CodingCase(
        match: .string("vimeo", at: "type"),
        values: [.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
    )
    case vimeo(id: String, duration: TimeInterval = 33, Int)
    
    @CodingCase(
        match: .intRange(20...24, at: "type.middle"),
        values: [.label("url", keys: "media")]
    )
    case tiktok(url: URL, tag: String?)
}

extension TestReerCodable {
    
    @Test
    func eunmWithAssociatedRange() throws {
        let json = """
        {
            "type": {
                "middle": 22
            },
            "media": "https://example.com/video.mp4",
            "tag": "Art"
        }
        """
        let model = try Video5.decoded(from: json.data(using: .utf8)!)
        
        switch model {
        case .tiktok(url: let url, tag: let tag):
            if json.lowercased().contains("22"),
               url.absoluteString == "https://example.com/video.mp4",
               tag == "Art" {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary
                #expect((dict?["type"] as? [String: Any])?.string("middle") == "tiktok")
                #expect(dict.string("url") == "https://example.com/video.mp4")
                #expect(dict.string("tag") == "Art")
            } else {
                Issue.record("Expected tiktok")
            }
        default: break
        }
    }
}


@Codable
enum Foo123 {
    @CodingCase(match: .string("Test123", at: "a.b"))
    case test
}

extension TestReerCodable {
    
    @Test
    func enumWithPath() throws {
        let json = """
        {
            "a": {
                "b": "Test123"
            }
        }
        """
        let model = try Foo123.decoded(from: json.data(using: .utf8)!)
        
        switch model {
        case .test:
            if json.contains("Test123") {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary
                #expect((dict?["a"] as? [String: Any])?.string("b") == "Test123")
            } else {
                Issue.record("Expected Test123")
            }
        }
    }
}

@Codable
enum Foo333 {
    @CodingCase(match: .string("test1", at: "a.b"))
    case test
    
    @CodingCase(match: .string("foo1", at: "f.d"))
    case foo
    
    @CodingCase(match: .string("bar1", at: "x"))
    case bar
}
extension TestReerCodable {
    @Test(arguments: [
        """
        {
            "a": {
                "b": "test1"
            }
        }
        """,
        """
        {
            "f": {
                "d": "foo1"
            }
        }
        """,
        """
        {
            "x": "bar1"
        }
        """
    ])
    func enumWithPath(json: String) throws {
        let model = try Foo333.decoded(from: json.data(using: .utf8)!)
        
        switch model {
        case .test:
            if json.contains("test1") {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary?["a"] as? [String: Any]
                #expect(dict.string("b") == "test1")
            } else {
                Issue.record("Expected test1")
            }
        case .foo:
            if json.contains("foo1") {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary?["f"] as? [String: Any]
                #expect(dict.string("d") == "foo1")
            } else {
                Issue.record("Expected foo1")
            }
        case .bar:
            if json.contains("bar1") {
                #expect(true)
                
                // Encode
                let modelData = try JSONEncoder().encode(model)
                let dict = modelData.stringAnyDictionary
                #expect(dict.string("x") == "bar1")
            } else {
                Issue.record("Expected bar1")
            }
        }
    }
}

// MARK: - Enum Case Style Tests

@Codable
@PascalCase
enum StatusWithStyle {
    case inProgress
    case notStarted
    case completed
}

@Codable
@SnakeCase
enum EventWithStyle {
    case pageView
    case buttonClick

    @PascalCase
    case appLaunch
}

@Codable
@PascalCase
enum MixedMatchEnum {
    @CodingCase(match: .string("pgview"))
    @SnakeCase
    case pageView

    case buttonClick
}

@Codable
@PascalCase
enum RawStringStyled: String {
    case fooBar = "foo-bar"
    case bazQux
}

@Codable
@SnakeCase
enum ActionWithAssoc {
    case doSomething(userId: Int, userName: String)
    case goBack
}

@Codable
@PascalCase
enum MixedCodingCaseAndStyle {
    @CodingCase(match: .int(8), .string("apple_phone"))
    @SnakeCase
    case iPhone

    case galaxyS
}

extension TestReerCodable {

    @Test
    func enumPascalCaseSimple() throws {
        let json1 = #"{"value": "InProgress"}"#
        let json2 = #"{"value": "NotStarted"}"#
        let json3 = #"{"value": "Completed"}"#

        struct Wrapper: Codable { let value: StatusWithStyle }

        let m1 = try Wrapper.decoded(from: json1.data(using: .utf8)!)
        #expect(m1.value == .inProgress)
        let m2 = try Wrapper.decoded(from: json2.data(using: .utf8)!)
        #expect(m2.value == .notStarted)
        let m3 = try Wrapper.decoded(from: json3.data(using: .utf8)!)
        #expect(m3.value == .completed)

        let encoded = try JSONEncoder().encode(m1)
        let dict = encoded.stringAnyDictionary
        #expect(dict.string("value") == "InProgress")

        let invalid = try? Wrapper.decoded(from: #"{"value": "inProgress"}"#.data(using: .utf8)!)
        #expect(invalid == nil)
    }

    @Test
    func enumSnakeCaseWithOverride() throws {
        struct Wrapper: Codable { let value: EventWithStyle }

        let j1 = try Wrapper.decoded(from: #"{"value": "page_view"}"#.data(using: .utf8)!)
        #expect(j1.value == .pageView)

        let j2 = try Wrapper.decoded(from: #"{"value": "button_click"}"#.data(using: .utf8)!)
        #expect(j2.value == .buttonClick)

        let j3 = try Wrapper.decoded(from: #"{"value": "AppLaunch"}"#.data(using: .utf8)!)
        #expect(j3.value == .appLaunch)

        let encoded1 = try JSONEncoder().encode(j1)
        #expect(encoded1.stringAnyDictionary.string("value") == "page_view")

        let encoded3 = try JSONEncoder().encode(j3)
        #expect(encoded3.stringAnyDictionary.string("value") == "AppLaunch")
    }

    @Test
    func enumUnionMatchCodingCaseAndStyle() throws {
        struct Wrapper: Codable { let value: MixedMatchEnum }

        let fromExplicit = try Wrapper.decoded(from: #"{"value": "pgview"}"#.data(using: .utf8)!)
        #expect(fromExplicit.value == .pageView)

        let fromSnake = try Wrapper.decoded(from: #"{"value": "page_view"}"#.data(using: .utf8)!)
        #expect(fromSnake.value == .pageView)

        let fromPascal = try Wrapper.decoded(from: #"{"value": "PageView"}"#.data(using: .utf8)!)
        #expect(fromPascal.value == .pageView)

        let fromButton = try Wrapper.decoded(from: #"{"value": "ButtonClick"}"#.data(using: .utf8)!)
        #expect(fromButton.value == .buttonClick)

        let encoded = try JSONEncoder().encode(fromExplicit)
        #expect(encoded.stringAnyDictionary.string("value") == "pgview")

        let encodedButton = try JSONEncoder().encode(fromButton)
        #expect(encodedButton.stringAnyDictionary.string("value") == "ButtonClick")
    }

    @Test
    func enumExplicitRawValueWithStyle() throws {
        struct Wrapper: Codable { let value: RawStringStyled }

        let fromRaw = try Wrapper.decoded(from: #"{"value": "foo-bar"}"#.data(using: .utf8)!)
        #expect(fromRaw.value == .fooBar)

        let fromPascal = try Wrapper.decoded(from: #"{"value": "FooBar"}"#.data(using: .utf8)!)
        #expect(fromPascal.value == .fooBar)

        let encoded = try JSONEncoder().encode(fromRaw)
        #expect(encoded.stringAnyDictionary.string("value") == "foo-bar")

        let bazFromPascal = try Wrapper.decoded(from: #"{"value": "BazQux"}"#.data(using: .utf8)!)
        #expect(bazFromPascal.value == .bazQux)

        let encodedBaz = try JSONEncoder().encode(bazFromPascal)
        #expect(encodedBaz.stringAnyDictionary.string("value") == "BazQux")
    }

    @Test
    func enumAssociatedValueWithStyle() throws {
        let json = #"{"do_something": {"user_id": 42, "user_name": "John"}}"#
        let model = try ActionWithAssoc.decoded(from: json.data(using: .utf8)!)

        switch model {
        case .doSomething(let userId, let userName):
            #expect(userId == 42)
            #expect(userName == "John")
        default:
            Issue.record("Expected doSomething")
        }

        let alsoValid = #"{"do_something": {"userId": 42, "userName": "John"}}"#
        let model2 = try ActionWithAssoc.decoded(from: alsoValid.data(using: .utf8)!)
        switch model2 {
        case .doSomething(let userId, let userName):
            #expect(userId == 42)
            #expect(userName == "John")
        default:
            Issue.record("Expected doSomething")
        }

        let encoded = try JSONEncoder().encode(model)
        let dict = encoded.stringAnyDictionary
        let nested = dict?["do_something"] as? [String: Any]
        #expect(nested != nil)
        #expect(nested.int("user_id") == 42)
        #expect(nested.string("user_name") == "John")

        let goBackJson = #"{"go_back": {}}"#
        let goBackModel = try ActionWithAssoc.decoded(from: goBackJson.data(using: .utf8)!)
        switch goBackModel {
        case .goBack:
            let goBackEncoded = try JSONEncoder().encode(goBackModel)
            let goBackDict = goBackEncoded.stringAnyDictionary
            #expect(goBackDict?["go_back"] != nil)
        default:
            Issue.record("Expected goBack")
        }
    }

    @Test
    func enumMixedIntAndStyleUnion() throws {
        struct Wrapper: Codable { let value: MixedCodingCaseAndStyle }

        let fromInt = try Wrapper.decoded(from: #"{"value": 8}"#.data(using: .utf8)!)
        #expect(fromInt.value == .iPhone)

        let fromString = try Wrapper.decoded(from: #"{"value": "apple_phone"}"#.data(using: .utf8)!)
        #expect(fromString.value == .iPhone)

        let fromSnake = try Wrapper.decoded(from: #"{"value": "i_phone"}"#.data(using: .utf8)!)
        #expect(fromSnake.value == .iPhone)

        let fromPascal = try Wrapper.decoded(from: #"{"value": "IPhone"}"#.data(using: .utf8)!)
        #expect(fromPascal.value == .iPhone)

        let fromGalaxy = try Wrapper.decoded(from: #"{"value": "GalaxyS"}"#.data(using: .utf8)!)
        #expect(fromGalaxy.value == .galaxyS)

        let encoded = try JSONEncoder().encode(fromInt)
        #expect(encoded.stringAnyDictionary.int("value") == 8)

        let encodedGalaxy = try JSONEncoder().encode(fromGalaxy)
        #expect(encodedGalaxy.stringAnyDictionary.string("value") == "GalaxyS")
    }
}
