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



enum Phone {
//    @CodingCase(.string("custom"), .int(10), value: [.init(index: 0, keys: )])
    case apple(String, width: Double)
    case huawei(String, width: Double)
}

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


enum Video: Codable {
    case youTube(id: String, TimeInterval)
    case vimeo(id: String)
    case hosted(url: URL)
}

extension Video {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
        if container.contains(AnyCodingKey(stringValue: "youTube")!) {
            let youTubeContainer = try container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "youTube")!
            )
            let id = try youTubeContainer.decode(
                String.self,
                forKey: AnyCodingKey(stringValue: "id")!
            )
            let duration = try youTubeContainer.decode(
                TimeInterval.self,
                forKey: AnyCodingKey(stringValue: "_1")! // 或者用 "_1"
            )
            self = .youTube(id: id, duration)
        }
        else if container.contains(AnyCodingKey(stringValue: "vimeo")!) {
            let vimeoContainer = try container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "vimeo")!
            )
            let id = try vimeoContainer.decode(
                String.self,
                forKey: AnyCodingKey(stringValue: "id")!
            )
            self = .vimeo(id: id)
        }
        else if container.contains(AnyCodingKey(stringValue: "hosted")!) {
            let hostedContainer = try container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "hosted")!
            )
            let url = try hostedContainer.decode(
                URL.self,
                forKey: AnyCodingKey(stringValue: "url")!
            )
            self = .hosted(url: url)
        }
        else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unrecognized Video type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        
        switch self {
        case let .youTube(id, duration):
            var youTubeContainer = container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "youTube")!
            )
            try youTubeContainer.encode(id, forKey: AnyCodingKey(stringValue: "id")!)
            try youTubeContainer.encode(duration, forKey: AnyCodingKey(stringValue: "duration")!)
            
        case let .vimeo(id):
            var vimeoContainer = container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "vimeo")!
            )
            try vimeoContainer.encode(id, forKey: AnyCodingKey(stringValue: "id")!)
            
        case let .hosted(url):
            var hostedContainer = container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: AnyCodingKey(stringValue: "hosted")!
            )
            try hostedContainer.encode(url, forKey: AnyCodingKey(stringValue: "url")!)
        }
    }
}

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
