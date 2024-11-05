import ReerCodable
import Foundation

let a = 17
let b = 25

@Codable
public final class Test {
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

//let modelData = try! JSONEncoder().encode(ret)
//let str = String(data: modelData, encoding: .utf8)
//print(str)
