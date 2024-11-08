import ReerCodable
import Foundation

let a = 17
let b = 25

@Codable
public final class Test {
    @CodingKey("age__", "a.b")
    var age: Int = 18
    var name: String
    let height: Float?

}


open class Person: Codable {
    var name: String?
   
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
//        self.name = try container.decode(String.self, forKey: .name)
        self.name = try container.decode(type: String?.self, keys: ["name"])
    }
    
    open func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
//        try container.encodeIfPresent(self.name, forKey: .init(stringValue: "name")!)
        try container.encode(value: self.name, key: "a.b.c", isNested: true)
    }
}


let ss = """
{"age": 22,
"as": {
    "b": 33
},
"a.b": 44,
"name": "phoenix",
"height": 180,
"tag": {
    "ed": "3333"
},
"tag.isdf": "hhhhhh",
"array": ["abc"],
"season": "spring"
}

"""
let data = ss.data(using: .utf8)!
let dict = try! JSONSerialization.jsonObject(with: data);

let ret = try! JSONDecoder().decode(Test.self, from: data)
print(ret)

let modelData = try! JSONEncoder().encode(ret)
let str = String(data: modelData, encoding: .utf8)
print(str)

@Codable
public class Model: Codable {
    var value: String
}

@CodableSubclass
public final class SubModel: Model {
    @CodingKey("sub")
    var subValue: String?
}

let jsonData = """
{
    "value": "super",
    "subValue": "sub"
}
""".data(using: .utf8)!

let model = try! JSONDecoder().decode(SubModel.self, from: jsonData)
print(model.subValue)

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
