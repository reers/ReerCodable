@testable import ReerCodable
import Testing
import Foundation

// MARK: - Normal

enum OnlyEncodable {
    @Encodable
    enum BloodType {
        case A, B, AB, O
    }

    @Encodable
    struct Child: Equatable {
        var name: String
        
        mutating func didDecode(from decoder: any Decoder) throws {
            name = "reer"
        }
        
        func willEncode(to encoder: any Encoder) throws {
            print(name)
        }
    }

    @Encodable
    struct Item: Equatable {
        let id: Int
    }

    @Encodable
    struct User3: Equatable {
        let name: String
    }

    @Encodable
    class Person1 {
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
}



let jsonData44 = """
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

extension TestReerCodable {

    @Test
    func person44() throws {
        let model = OnlyEncodable.Person1(
            name: "phoenix",
            age: 33,
            weight: 75.0,
            a_b: "abtest",
            childs: [OnlyEncodable.Child(name: "reer")],
            spouse: "NYC",
            isMale: true,
            withoutTypeDefine: 233,
            ignore: [],
            data: "hello world".data(using: .utf8),
            array: ["a", "b", "c"],
            items: [.init(id: 1), .init(id: 2)],
            dict: ["a": .init(name: "Alice")],
            uniqueIds: ["a", "b"],
            bloodType: nil
        )
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
