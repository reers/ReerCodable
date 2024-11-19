import ReerCodable
import Foundation

let a = 17
let b = 25

//@Codable
//struct Test {
//    var age: Int
//    
//    func didDecodeModel() throws {
//
//    }
//}

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
    
    public func didDecode() throws {
        var ss: String?
//        print(ss?.re_base64DecodedData()?.re_bytes)
        userAge = 22
        if userAge < 0 {
            throw ReerCodableError(text: "这是一个测试错误")
        }
    }
    
    public func willEncode() throws {
        userAge = 100
        
    }
}

public struct IgnoreModel: Codable {
    
}



open class Person: Decodable {
    
    var array: [String]?
    var dict: [String: String]
    var set: Set<String>
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.array = try? container.compactDecodeArray(type: [String].self, keys: ["array.xxx"])
//        self.array = try container.compactDecodeOptionalArray(type: [String]?.self, keys: ["array"])
        
        // 1. Array compact decoding
//        var arrayContainer = try container.nestedUnkeyedContainer(forKey: AnyCodingKey(stringValue: "array")!)
//        var tempArray: [String] = []
//        
//        while !arrayContainer.isAtEnd {
//            if let element = try? arrayContainer.decode(String.self) {
//                tempArray.append(element)
//            } else {
//                _ = try? arrayContainer.decodeNil()
//            }
//        }
//        self.array = tempArray
        
        // 2. Dictionary compact decoding
        let dictContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey(stringValue: "dict")!)
        var tempDict: [String: String] = [:]
        
        for key in dictContainer.allKeys {
            if let value = try? dictContainer.decode(String.self, forKey: key) {
                tempDict[key.stringValue] = value
            }
        }
        self.dict = tempDict
        
        // 3. Set compact decoding
//        var setContainer = try container.nestedUnkeyedContainer(forKey: AnyCodingKey(stringValue: "set")!)
//        var tempSet: Set<String> = []
//        
//        while !setContainer.isAtEnd {
//            if let element = try? setContainer.decode(String.self) {
//                tempSet.insert(element)
//            } else {
//                _ = try? setContainer.decodeNil()
//            }
//        }
        
        self.set = try {
            Set(try container.compactDecodeArray(type: [String].self, keys: ["set"]))
        }()
    }
}


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
"season": "spring",
"data": "aGVsbG8gd29ybGQ=",
"date": 1731585275944
}

"""
let data = ss.data(using: .utf8)!
let dict = try! JSONSerialization.jsonObject(with: data);


let ret = try JSONDecoder().decode(Test.self, from: data)
print(ret)

let modelData = try! JSONEncoder().encode(ret)
let str = String(data: modelData, encoding: .utf8)
print(str)

//@Codable
//public class Model: Codable {
//    var value: String
//}
//
//@CodableSubclass
//public final class SubModel: Model {
//    @CodingKey("sub")
//    var subValue: String?
//}
//
//let jsonData = """
//{
//    "value": "super",
//    "subValue": "sub"
//}
//""".data(using: .utf8)!
//
//let model = try! JSONDecoder().decode(SubModel.self, from: jsonData)
//print(model.subValue)

//@Codable
//public class Model: Codable {
//    var value: String
//}
//
////@CodableSubclass
//public final class SubModel: Model {
////    @CodingKey("sub")
//    var subValue: String?
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: AnyCodingKey.self)
//        self.subValue = try container.decode(type: String?.self, keys: ["sub", "subValue"])
//        try super.init(from: decoder)
//    }
//
//    public override func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: AnyCodingKey.self)
//        try container.encode(value: self.subValue, key: "sub", isNested: false)
//    }
//}

let presonData = """
{
"array": {
    "xxx": ["a", null, "b", null, "c"]
},
"dict": {
        "key1": "value1",
        "key2": null,
        "key3": "value3"
    },
"set": ["x", null, "y", null, "z"]
}
""".data(using: .utf8)!
let rettt = try! JSONDecoder().decode(Person.self, from: presonData)
print(rettt)
