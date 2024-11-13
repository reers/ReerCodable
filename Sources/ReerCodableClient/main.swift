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



open class Person: Codable {
    var name: String?
   
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
//        self.name =
//        self.name = try container.decode(String.self, forKey: .name)
//        self.name = try {
//            let tempValue = try container.decode(type: String?.self, keys: ["name"])
//            return tempValue?.base64DecodedData
//        }()
    }
    
    open func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
//        try container.encodeIfPresent(self.name, forKey: .init(stringValue: "name")!)
        try container.encode(value: self.name, key: "a.b.c", treatDotAsNested: true)
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
"array": ["abc"],
"season": "spring",
"data": "aGVsbG8gd29ybGQ="
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

