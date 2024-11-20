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



//let formatter = DateFormatter()
//formatter.locale = Locale(identifier: "en_US_POSIX")
//formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
//formatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//@Codable
//@SnakeCase
//@ScreamingKebabCase
//public final class Test {
//    @CodingKey("age__", "a.b")
//    var userAge: Int = 18
//    
//    @CodingKey("name")
//    var userName: String
////    @Base64Coding
////    let height: [UInt8]?
//    
//    @IgnoreCoding
//    var ignore: Set<String>
//    
//    @Base64Coding
//    var data: Data?
//    
//    @CodingKey("data.data2")
//    @Base64Coding
//    var data2: Data?
//    
//    @DateCoding(.millisecondsSince1970)
//    var date: Date?
//    
//    @CodingKey("array.xxx")
//    @EncodingKey("iamset")
//    @CompactDecoding
//    var array: Set<String>
//    
//    
//    @CompactDecoding
//    var dict: [String: String]
//    
//    @CustomCoding(
//        decode: { decoder in
////            let container = try decoder.container(keyedBy: AnyCodingKey.self)
////            let ret = try container.decode(Int.self, forKey: AnyCodingKey(stringValue: "custom")!)
////            return ret * 1000
//            if let ret: Int = decoder["custom"] {
//                return ret * 1000
//            } else {
//                return 0
//            }
//        },
//        encode: { (encoder: Encoder, value: Int) in
////            print(333333)
////            var container = try encoder.container(keyedBy: AnyCodingKey.self)
////            try container.encode(66666, forKey: AnyCodingKey(stringValue: "custom")!)
//            
//            encoder["custom"] = 66666
//        }
//    )
//    var custom: Int
//    
//    var theme: Theme?
//    
//    public func didDecode() throws {
//        var ss: String?
////        print(ss?.re_base64DecodedData()?.re_bytes)
//        userAge = 22
//        if userAge < 0 {
//            throw ReerCodableError(text: "这是一个测试错误")
//        }
//    }
//    
//    public func willEncode() throws {
//        userAge = 100
//        
//    }
//}
//
//public struct IgnoreModel: Codable {
//    
//}
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
//let ss = """
//{"age__": 22,
//"as": {
//    "b": 33
//},
//"a.b": "-44",
//"name": "phoenix",
//"height": "180",
//"tag": {
//    "ed": "3333"
//},
//"tag.isdf": "hhhhhh",
//"array": {
//    "xxx": ["a", null, "b", null, "c"]
//},
//"dict": {
//        "111": null,
//        "222": null,
//        "333": "value3"
//    },
//"season": "spring",
//"data": "aGVsbG8gd29ybGQ=",
//"date": 1731585275944,
//"custom": 111,
//"theme": {
//    "custom": {
//        "hex": "#ff0000"
//    }
//}
//}
//
//"""
//let data = ss.data(using: .utf8)!
//let dict = try! JSONSerialization.jsonObject(with: data);
//
//
//let ret = try JSONDecoder().decode(Test.self, from: data)
//print(ret)
//
//let modelData = try! JSONEncoder().encode(ret)
//let str = String(data: modelData, encoding: .utf8)
//print(str)
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

//@Codable
enum Season: Double {
    
    case spring = 1.5, summer = 2.5
}

enum Video: Codable {
    case youTube(id: String)
    case vimeo(id: String)
    case hosted(url: URL)
}

@Codable
public enum Theme {
    @CodingCaseKey(case: "white")
    case white
    case black
    case custom(hex: String)
}

@Codable
struct Test {
    var theme: Theme
}


let data = """
{
"theme": {
    "custom": {
        "hex": "#ff0000"
    }
}
}
""".data(using: .utf8)!
let ret = try! Test.decoded(from: data)
print(ret)
