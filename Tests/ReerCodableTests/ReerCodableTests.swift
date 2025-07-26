@testable import ReerCodable
import Testing
import Foundation

// MARK: - Normal

@Codable
enum BloodType {
    case A, B, AB, O
}

@Codable
struct Child: Equatable {
    var name: String
    
    mutating func didDecode(from decoder: any Decoder) throws {
        name = "reer"
    }
    
    func willEncode(to encoder: any Encoder) throws {
        print(name)
    }
}

@Codable
struct Item: Equatable {
    let id: Int
}

@Codable
struct User3: Equatable {
    let name: String
}

@Codable
class Person1: Codable {
    @CodingKey("user_name")
    let name: String
    
    @CodingKey("user_age")
    @EncodingKey("age")
    var age: Int
    
    @CodingKey("other_info.weight")
    var weight: Double
    
    @CodingKey("a.b")
    @EncodingKey("a.b", treatDotAsNested: false)
    var a_b: String
    
    var childs: [Child] = []
    
    var spouse: String? = "nyc"
    
    @CodingKey("is_male")
    @FlexibleType
    var isMale: Bool
    
    var withoutTypeDefine = 233
    
    @CodingIgnored
    var ignore: Set<String>
    
    @Base64Coding
    var data: Data?
    
    @CodingKey("other_info.array")
    @EncodingKey("i_am_array")
    @CompactDecoding
    var array: [String]
    
    @CompactDecoding
    var items: [Item]
    
    @CompactDecoding
    var dict: [String: User3]
    
    @CompactDecoding
    var uniqueIds: Set<String>
    
    // Optional enum decoding will not throw a error if not exist
    var bloodType: BloodType?
    
    func didDecode(from decoder: any Decoder) throws {
        if age < 0 {
            throw ReerCodableError(text: "wrong age")
        }
    }
    
    func willEncode(to encoder: any Encoder) throws {
        age = 18
    }
}

let jsonData = """
{
    "user_name": "phoenix",
    "user_age": 33,
    "other_info": {
        "weight": 75.0,
        "array": ["a", null, "b", null, "c"]
    },
    "a.b": "abtest",
    "childs": [
        {
            "name": "nic"
        }
    ],
    "spouse": "NYC",
    "is_male": "1",
    "data": "aGVsbG8gd29ybGQ=",
    "items": [{"id": 1},  {"id": 2}, {"invalid": true}],
    "dict": {"a": {"name": "Alice"}, "b": null, "c": {"invalid": true}},
    "uniqueIds": ["a", null, "b", "a"]
}
""".data(using: .utf8)!


struct TestReerCodable {

    @Test
    func person1() throws {
        // Decode
        let model = try JSONDecoder().decode(Person1.self, from: jsonData)
        #expect(model.name == "phoenix")
        #expect(model.age == 33)
        #expect(model.weight == 75.0)
        #expect(model.a_b == "abtest")
        #expect(model.childs == [Child(name: "reer")])
        #expect(model.spouse == "NYC")
        #expect(model.isMale == true)
        #expect(model.withoutTypeDefine == 233)
        #expect(model.ignore == [])
        #expect(model.data?.utf8String == "hello world")
        #expect(model.array == ["a", "b", "c"])
        #expect(model.bloodType == nil)
        #expect(model.items == [.init(id: 1), .init(id: 2)])
        #expect(model.dict == ["a": .init(name: "Alice")])
        #expect(model.uniqueIds == ["a", "b"])
        
        model.ignore = Set(arrayLiteral: "1", "2")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        
        #expect(dict.string("user_name") == "phoenix")
        #expect(dict.int("age") == 18)
        let otherInfo = dict?["other_info"] as? [String: Any]
        #expect(otherInfo.double("weight") == 75.0)
        #expect(dict.string("a.b") == "abtest")
        let childs = (dict?["childs"] as? [[String:Any]])?.first
        #expect(childs.string("name") == "reer")
        #expect(dict.string("spouse") == "NYC")
        #expect(dict.int("is_male") == 1)
        #expect(dict.int("withoutTypeDefine") == 233)
        #expect(dict?["ignore"] == nil)
        #expect(dict.string("data") == "aGVsbG8gd29ybGQ=")
        #expect(dict?["i_am_array"] as? [String] == ["a", "b", "c"])
    }
}

// MARK: - Recursive


@Codable
class Person4 {
    var name: String = ""
    var parent: Person4?
}
 
let json4: [String: Any] = [
    "name": "Jack",
    "parent": ["name": "Jim"]
]

extension TestReerCodable {
    @Test
    func recursive() throws {
        // Decode
        let model = try Person4.decoded(from: json4)
        #expect(model.name == "Jack")
        #expect(model.parent?.name == "Jim")
        
        // Encode
        let dict = try model.encodedDict()
        #expect(dict.string("name") == "Jack")
        #expect(dict["parent"] as! [String : String] == ["name": "Jim"])
        print(dict)
    }
}

// MARK: - Generic Type

@Codable
struct NetResponse<Element: Codable> {
    let data: Element?
    let msg: String
    private(set) var code: Int = 0
}

@Codable
struct User4 {
    @FlexibleType
    let id: String
    let nickName: String
}

@Codable
struct Goods {
    @FlexibleType
    private(set) var price: CGFloat = 0.0
    let name: String
}
 
let json1 = """
{
    "data": {"nickName": "phoenix", "id": 123123},
    "msg": "success",
    "code" : 200
}
"""

let json2 = """
{
    "data": [
        {"price": "6199", "name": "iPhone XR"},
        {"price": "8199", "name": "iPhone XS"},
        {"price": "9099", "name": "iPhone Max"}
    ],
    "msg": "success",
    "code" : 200
}
"""

extension TestReerCodable {
    @Test
    func generic1() throws {
        // Decode
        let model = try NetResponse<User4>.decoded(from: json1)
        #expect(model.msg == "success")
        #expect(model.code == 200)
        #expect(model.data?.nickName == "phoenix")
        #expect(model.data?.id == "123123")
        
        
        // Encode
        let dict = try model.encodedDict()
        #expect(dict.string("msg") == "success")
        #expect(dict.int("code") == 200)
        if let data = dict["data"] as? [String : Any] {
            #expect(data.string("nickName") == "phoenix")
            #expect(data.string("id") == "123123")
        }
        print(dict)
    }
    
    @Test
    func generic2() throws {
        // Decode
        let model = try NetResponse<[Goods]>.decoded(from: json2)
        #expect(model.msg == "success")
        #expect(model.code == 200)
        
        #expect(model.data?.count == 3)
        #expect(model.data?[0].price == 6199)
        #expect(model.data?[0].name == "iPhone XR")
        #expect(model.data?[1].price == 8199)
        #expect(model.data?[1].name == "iPhone XS")
        #expect(model.data?[2].price == 9099)
        #expect(model.data?[2].name == "iPhone Max")
        
        // Encode
        let dict = try model.encodedDict()
        #expect(dict.string("msg") == "success")
        #expect(dict.int("code") == 200)
        if let data = dict["data"] as? [[String : Any]] {
            #expect(data[0].double("price") == 6199)
            #expect(data[1].double("price") == 8199)
            #expect(data[2].double("price") == 9099)
            
            #expect(data[0].string("name") == "iPhone XR")
            #expect(data[1].string("name") == "iPhone XS")
            #expect(data[2].string("name") == "iPhone Max")
        }
        print(dict)
    }
}

// MARK: - Model Array

@Codable
struct Car {
    var name: String = ""
    var price: Double = 0.0
}
let json5: [[String: Any]] = [
    ["name": "Benz", "price": 98.6],
    ["name": "Bently", "price": 305.7],
    ["name": "Audi", "price": 64.7]
]

extension TestReerCodable {
    @Test
    func modelArray() throws {
        let models = try [Car].decoded(from: json5)
        #expect(models[2].name == "Audi")
        #expect(models[1].price == 305.7)
    }
}

// MARK: - Nested Model

enum Top {
    @Codable
    struct User {
        let name: String
    }
}
let json6 = [
    "name": "phoenix"
]
extension TestReerCodable {
    @Test
    func nestedModel() throws {
        let model = try Top.User.decoded(from: json6)
        #expect(model.name == "phoenix")
        
        let dict = try model.encodedDict()
        #expect(dict.string("name") == "phoenix")
    }
}
