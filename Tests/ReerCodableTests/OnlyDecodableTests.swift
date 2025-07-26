@testable import ReerCodable
import Testing
import Foundation

// MARK: - Normal

enum OnlyDecodable {
    @Decodable
    enum BloodType {
        case A, B, AB, O
    }

    @Decodable
    struct Child: Equatable {
        var name: String
        
        mutating func didDecode(from decoder: any Decoder) throws {
            name = "reer"
        }
        
        func willEncode(to encoder: any Encoder) throws {
            print(name)
        }
    }

    @Decodable
    struct Item: Equatable {
        let id: Int
    }

    @Decodable
    struct User3: Equatable {
        let name: String
    }

    @Decodable
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
}



let jsonData33 = """
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
    func person33() throws {
        // Decode
        let model = try JSONDecoder().decode(OnlyDecodable.Person1.self, from: jsonData33)
        #expect(model.name == "phoenix")
        #expect(model.age == 33)
        #expect(model.weight == 75.0)
        #expect(model.a_b == "abtest")
        #expect(model.childs == [OnlyDecodable.Child(name: "reer")])
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
        
    }
}
