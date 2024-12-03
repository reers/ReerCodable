import ReerCodable
import Foundation

//let a = 17
//let b = 25

//@Codable
//struct Test {
//    var age: Int
//
//    func didDecodeModel() throws {
//
//    }
//}

struct IntTransformer: CodingCustomizable {
    typealias Value = Int
    
    static func decode(by decoder: any Decoder) throws -> Int {
        let temp: Int = try decoder.value(forKeys: "custom")
        return temp * 1000
    }
    
    static func encode(by encoder: any Encoder, _ value: Int) throws {
        try encoder.set(value, forKey: "custom_by")
    }
}



let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
formatter.timeZone = TimeZone(secondsFromGMT: 0)

@Codable
@SnakeCase
@ScreamingKebabCase
public final class Test {
    @CodingKey("age__", "a.b")
    var userAge: Int = 18
    
    @CodingKey("name")
    var userName: String
//    @Base64Coding
//    let height: [UInt8]?
    
    @IgnoreCoding
    var ignore: Set<String>
    
    @Base64Coding
    var data: Data?
    
    @CodingKey("data.data2")
    @Base64Coding
    var data2: Data?
    
    @DateCoding(.millisecondsSince1970)
    var date: Date?
    
    @CodingKey("array.xxx")
    @EncodingKey("iamset")
    @CompactDecoding
    var array: Set<String>
    
    
    @CompactDecoding
    var dict: [String: String]
    
    @CustomCoding<Int>(
        decode: { decoder in
            let temp: Int = try decoder.value(forKeys: "custom")
            return temp * 1000
        },
        encode: { encoder, value in
            try encoder.set(value, forKey: "custom")
        }
    )
    var custom: Int
    
    @CustomCoding(IntTransformer.self)
    var customBy: Int
    
    var theme: Theme?
    
    public func didDecode(from decoder: any Decoder) throws {
        var ss: String?
//        print(ss?.re_base64DecodedData()?.re_bytes)
        userAge = 22
        if userAge < 0 {
            throw ReerCodableError(text: "这是一个测试错误")
        }
    }
    
    public func willEncode(to encoder: any Encoder) throws {
        userAge = 100
        
    }
}

public struct IgnoreModel: Codable {
    
}
//
//
//
//open class Person: Codable {
//    
//    var array: [String]?
//    var dict: [Int: String]
//    var set: Set<String>
//    var int: Int
//    
//    required public init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: AnyCodingKey.self)
//        self.array = try? container.compactDecodeArray(type: [String].self, keys: ["array.xxx"])
//        
//        self.int = try { decoder in
//            return 222222
//        }(decoder)
////        self.array = try container.compactDecodeOptionalArray(type: [String]?.self, keys: ["array"])
//        
//        // 1. Array compact decoding
////        var arrayContainer = try container.nestedUnkeyedContainer(forKey: AnyCodingKey(stringValue: "array")!)
////        var tempArray: [String] = []
////
////        while !arrayContainer.isAtEnd {
////            if let element = try? arrayContainer.decode(String.self) {
////                tempArray.append(element)
////            } else {
////                _ = try? arrayContainer.decodeNil()
////            }
////        }
////        self.array = tempArray
//        
//        // 2. Dictionary compact decoding
////        let dictContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey(stringValue: "dict")!)
////        var tempDict: [String: String] = [:]
////
////        for key in dictContainer.allKeys {
////            if let value = try? dictContainer.decode(String.self, forKey: key) {
////                tempDict[key.stringValue] = value
////            }
////        }
//        self.dict = try container.compactDecodeDictionary(type: [Int: String].self, keys: ["dict"])
//        
//        // 3. Set compact decoding
////        var setContainer = try container.nestedUnkeyedContainer(forKey: AnyCodingKey(stringValue: "set")!)
////        var tempSet: Set<String> = []
////
////        while !setContainer.isAtEnd {
////            if let element = try? setContainer.decode(String.self) {
////                tempSet.insert(element)
////            } else {
////                _ = try? setContainer.decodeNil()
////            }
////        }
//        
//        self.set = try {
//            Set(try container.compactDecodeArray(type: [String].self, keys: ["set"]))
//        }()
//    }
////    public func encode(to encoder: any Encoder) throws {
//////        var container = encoder.container(keyedBy: AnyCodingKey.self)
//////        try container.encode(value: self.userAge, key: "age__", treatDotAsNested: true)
////        { encoder, value  in
////            print(333333)
////        }(encoder, self.int)
////    }
//}
//
//
let ss = """
{"age__": 22,
"as": {
    "b": 33
},
"a.b": "-44",
"name": "phoenix",
"height": "180",
"tag": {
    "ed": "3333"
},
"tag.isdf": "hhhhhh",
"array": {
    "xxx": ["a", null, "b", null, "c"]
},
"dict": {
        "111": null,
        "222": null,
        "333": "value3"
    },
"season": "spring",
"data": "aGVsbG8gd29ybGQ=",
"date": 1731585275944,
"custom": 111,
"theme": {
    "custom": {
        "hex": "#ff0000"
    }
}
}

"""
let data = ss.data(using: .utf8)!
let dict = try! JSONSerialization.jsonObject(with: data);


let ret = try JSONDecoder().decode(Test.self, from: data)
print(ret)

let modelData = try! JSONEncoder().encode(ret)
let str = String(data: modelData, encoding: .utf8)
print(str)
//
//
//let presonData = """
//{
//"array": {
//    "xxx": ["a", null, "b", null, "c"]
//},
//"dict": {
//        "111": "value1",
//        "222": null,
//        "333": "value3"
//    },
//"set": ["x", null, "y", null, "z"]
//}
//""".data(using: .utf8)!
//let rettt = try! JSONDecoder().decode(Person.self, from: presonData)
//print(rettt)
//let data342: String = try rettt.encodedString()

// Only String-based raw type enums are supported when using @CodingCaseKey
@Codable
enum Season: Double, Codable {
    case spring
    case summer = 43
    case fall
    
}
enum Season2: UInt8 {
    case spring, summer = 43, fall
}


//@Codable
public enum Theme: Codable {
//    @CodingCaseKey("white", value: [.init(label: "hex", keys: "HEX", "color")])
    case white
    case black
    
//    @CodingCaseKey(
//        "white",
//        value: [
//            .init(label: "hex", keys: "HEX", "color"),
//            .init(index: 1, keys: "alpha")
//        ]
//    )
    case custom(hex: String, CGFloat)
}

//@Codable
struct Test2: Codable {
    var theme: Theme
    var season: Season
}


let data2 = """
{
"theme": {
    "custom": {
        "hex": "#ff0000",
        "_1": 0.3
    }
},
"season": 44
}
""".data(using: .utf8)!
let ret2 = try! Test2.decoded(from: data2)
print(try ret2.encodedDict())
print(ret)



//enum Phone {
////    @CodingCase(.string("custom"), .int(10), value: [.init(index: 0, keys: )])
//    case apple(String, width: Double)
//    case huawei(String, width: Double)
//}

enum Gender: Int, Codable {
//    @CodingCase(.int(0), .string("male"))
    case male = 0
    case female = 1
    
    // Custom decoder implementation
    init(from decoder: Decoder) throws {
        // Try to decode as String first
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self) {
            switch stringValue.lowercased() {
            case "male", "m":
                self = .male
            case "female", "f":
                self = .female
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid gender string: \(stringValue)"
                )
            }
        } else {
            // Fallback to default Int decoding
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(Int.self)
            guard let gender = Gender(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid gender value: \(rawValue)"
                )
            }
            self = gender
        }
    }
    
    // Custom encoder implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        // Encode as String for better readability
        switch self {
        case .male:
            try container.encode("male")
        case .female:
            try container.encode("female")
        }
    }
}

// Testing the implementation
let jsonString = """
{
    "gender1": "male",
    "gender2": "f",
    "gender3": 0
}
"""

struct Person: Codable {
    let gender1: Gender
    let gender2: Gender
    let gender3: Gender
}

do {
    let decoder = JSONDecoder()
    let person = try decoder.decode(Person.self, from: jsonString.data(using: .utf8)!)
    print(person.gender1) // male
    print(person.gender2) // female
    print(person.gender3) // male
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(person)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print("Error: \(error)")
}

@Codable
enum Video: Codable {
    case youTube(id: String, TimeInterval)
    case vimeo(id: String)
    case hosted(url: URL)
}

//extension Video {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: AnyCodingKey.self)
//
//        guard container.allKeys.count == 1 else {
//            throw ReerCodableError(text: "Invalid number of keys found, expected one.")
//        }
//        if let nestedContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("youTube")) {
//            let id = try nestedContainer.decode(String.self, forKey: AnyCodingKey("id"))
//            let duration = try nestedContainer.decode(TimeInterval.self, forKey: AnyCodingKey("_1"))
//            self = .youTube(id: id, duration)
//        } else if let nestedContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("vimeo")) {
//            let id = try nestedContainer.decode(String.self, forKey: AnyCodingKey("id"))
//            self = .vimeo(id: id)
//        } else if let nestedContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("hosted")) {
//            let url = try nestedContainer.decode(URL.self, forKey: AnyCodingKey("url"))
//            self = .hosted(url: url)
//        } else {
//            throw ReerCodableError(text: "Key not found for \\(String(describing: Self.self)).")
//        }
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: AnyCodingKey.self)
//        
//        switch self {
//        case let .youTube(id, duration):
//            var nestedContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("youTube"))
//            try nestedContainer.encode(id, forKey: AnyCodingKey("id"))
//            try nestedContainer.encode(duration, forKey: AnyCodingKey("duration"))
//        case let .vimeo(id):
//            var nestedContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("vimeo"))
//            try nestedContainer.encode(id, forKey: AnyCodingKey("id"))
//        case let .hosted(url):
//            var nestedContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey("hosted"))
//            try nestedContainer.encode(url, forKey: AnyCodingKey("url"))
//        }
//    }
//}

struct Response: Codable {
    let name: String
    let videos: [Video]
}

let videoJson = """
{
    "name": "Conference talks",
    "videos": [
        {
            "youTube": {
                "id": "ujOc3a7Hav0",
                "_1": 44.5
            }
        },
        {
            "vimeo": {
                "id": "234961067"
            }
        }
    ]
}
""".data(using: .utf8)!
let resp = try! Response.decoded(from: videoJson)
print(resp)
let respdict = try! resp.encodedDict()
print(respdict)

//@Codable
//enum Phone: Decodable {
////    @CodingCase(match: .bool(true), .int(8), .string("youtube"))
//    case apple
//    case mi
//    case oppo
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        // 尝试解码为不同类型
//        if let boolValue = try? container.decode(Bool.self) {
//            switch boolValue {
//            case true:
//                self = .apple
//                return
//            default: break
//            }
//        }
//
//        if let intValue = try? container.decode(Int.self) {
//            switch intValue {
//            case 8:
//                self = .apple
//                return
//            default: break
//            }
//        }
//        let stringValue = try container.decode(String.self)
//        switch stringValue {
//        case "youtube":
//            self = .apple
//        case "mi":
//            self = .mi
//        case "oppo":
//            self = .oppo
//        default:
//            throw DecodingError.dataCorruptedError(
//                in: container,
//                debugDescription: "Cannot initialize Phone from invalid value: \(stringValue)"
//            )
//        }
//    }
//}
@Codable
enum Phone: Codable {
    @CodingCase(match: .bool(true), .int(8), .int(10), .string("youtube"), .string("Apple"))
    case apple
    
    @CodingCase(match: .int(12), .string("MI"), .string("xiaomi"))
    case mi
    
    @CodingCase(match: .bool(false))
    case oppo
}

struct Resp2: Codable {
    let phone: Phone
}

let phoneData = """
{
"phone": false
}
""".data(using: .utf8)!
let resp2 = try! Resp2.decoded(from: phoneData)
print(resp2)

let videoJson3_1 = """
{
    "name": "Conference talks",
    "videos": [
        {
            "youtube": {
                "id": "ujOc3a7Hav0",
                "_1": 44.5
            }
        },
        {
            "vimeo": {
                "ID": "234961067",
                "minutes": 999999
            }
        },
        {
            "hosted": {
                "url": "https://example.com/video.mp4",
                "tag": "Art"
            }
        }
    ]
}
""".data(using: .utf8)!

let videoJson3_2 = """
{
    "name": "Conference talks",
    "videos": [
        {
            "type": "youtube"
        },
        {
            "type": "vimeo",
            "ID": "234961067"
        },
        {
            "type": "hosted",
            "url": "https://example.com/video.mp4"
        }
    ]
}
""".data(using: .utf8)!

@Codable
enum Video3: Codable {
    @CodingCase(match: .string("youtube"))
    case youTube
    
    @CodingCase(
        match: .string("vimeo"),
        values: [CaseValue(label: "id", keys: "ID", "Id"), .init(index: 2, keys: "minutes")]
    )
    case vimeo(id: String, duration: TimeInterval = 33, Int)
    
    @CodingCase(
        match: .string("hosted"),
        values: [.init(label: "url", keys: "url")]
    )
    case hosted(url: URL, tag: String?)
}
struct Resp3: Codable {
    let name: String
    let videos: [Video3]
}

let result3 = try! Resp3.decoded(from: videoJson3_1)
print(result3)
