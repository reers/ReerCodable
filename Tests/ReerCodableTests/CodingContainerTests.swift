@testable import ReerCodable
import Testing
import Foundation

@Codable
@CodingContainer("data.info")
struct UserInfo {
    var name: String
    var age: Int
}

@Codable
@CodingContainer("data.info", workForEncoding: true)
struct UserInfo2 {
    var name: String
    var age: Int
}


let containerJson = """
{
    "code": 0,
    "data": {
        "info": {
            "name": "phoenix",
            "age": 33
        }
    }
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func codingContainer() throws {
        // Decode
        let model = try JSONDecoder().decode(UserInfo.self, from: containerJson)
        #expect(model.name == "phoenix")
        #expect(model.age == 33)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("name") == "phoenix")
        #expect(dict.int("age") == 33)
    }
    
    @Test
    func codingContainer2() throws {
        // Decode
        let model = try JSONDecoder().decode(UserInfo2.self, from: containerJson)
        #expect(model.name == "phoenix")
        #expect(model.age == 33)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        let dataDict = dict?["data"] as? [String: Any]
        let infoDict = dataDict?["info"] as? [String: Any]
        #expect(infoDict.string("name") == "phoenix")
        #expect(infoDict.int("age") == 33)
    }
}
