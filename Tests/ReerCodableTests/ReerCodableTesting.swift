import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ReerCodable
import Testing
import Foundation

@Codable
enum BloodType {
    case A, B, AB, O
}

@Codable
struct Child: Equatable {
    var name: String
}

@Codable
struct Person1: Codable {
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
    var isMale: Bool
    
    @CodingIgnored
    var ignore: Set<String>
    
    @Base64Coding
    var data: Data?
    
    @CodingKey("other_info.array")
    @EncodingKey("i_am_array")
    @CompactDecoding
    var array: [String]
    
    // Optional enum decoding will not throw a error if not exist
    var bloodType: BloodType?
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
    "data": "aGVsbG8gd29ybGQ="
}
""".data(using: .utf8)!


struct TestReerCodable {

    @Test
    func person1() throws {
        // Decode
        var model = try JSONDecoder().decode(Person1.self, from: jsonData)
        #expect(model.name == "phoenix")
        #expect(model.age == 33)
        #expect(model.weight == 75.0)
        #expect(model.a_b == "abtest")
        #expect(model.childs == [Child(name: "nic")])
        #expect(model.spouse == "NYC")
        #expect(model.isMale == true)
        #expect(model.ignore == [])
        #expect(model.data?.utf8String == "hello world")
        #expect(model.array == ["a", "b", "c"])
        #expect(model.bloodType == nil)
        
        model.ignore = Set(arrayLiteral: "1", "2")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        
        #expect(dict.string("user_name") == "phoenix")
        #expect(dict.int("age") == 33)
        let otherInfo = dict?["other_info"] as? [String: Any]
        #expect(otherInfo.double("weight") == 75.0)
        #expect(dict.string("a.b") == "abtest")
        let childs = (dict?["childs"] as? [[String:Any]])?.first
        #expect(childs.string("name") == "nic")
        #expect(dict.string("spouse") == "NYC")
        #expect(dict.int("is_male") == 1)
        #expect(dict?["ignore"] == nil)
        #expect(dict.string("data") == "aGVsbG8gd29ybGQ=")
        #expect(dict?["i_am_array"] as? [String] == ["a", "b", "c"])
    }
}
