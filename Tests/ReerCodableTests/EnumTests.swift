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
        #expect(dict.string("phone") == "iPhone")
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
        #expect(dict.string("phone") == "xiaomi")
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
        #expect(dict.string("phone") == "oppo")
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
                let index = modelData.stringAnyDictionary?.index(forKey: "youTube")
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
                #expect(dict.string("middle") == "youTube")
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
                #expect((dict?["type"] as! [String: Any]).string("middle") == "tiktok")
                #expect(dict.string("url") == "https://example.com/video.mp4")
                #expect(dict.string("tag") == "Art")
            } else {
                Issue.record("Expected tiktok")
            }
        default: break
        }
    }
}
