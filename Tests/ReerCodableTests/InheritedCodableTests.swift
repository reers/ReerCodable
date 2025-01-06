@testable import ReerCodable
import Testing
import Foundation

@Codable
class Animal {
    var name: String
    func didDecode(from decoder: any Decoder) throws {
        
    }
    
    func willEncode(to encoder: any Encoder) throws {
        
    }
}

@InheritedCodable
class Cat: Animal {
    var color: String
    
    override func didDecode(from decoder: any Decoder) throws {
        try super.didDecode(from: decoder)
    }
    
    override func willEncode(to encoder: any Encoder) throws {
        try super.willEncode(to: encoder)
    }
}

let jsonData3 = """
{
    "name": "Little Trouble",
    "color": "black"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func inherited() throws {
        // Decode
        let model = try JSONDecoder().decode(Cat.self, from: jsonData3)
        #expect(model.name == "Little Trouble")
        #expect(model.color == "black")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("name") == "Little Trouble")
        #expect(dict.string("color") == "black")
    }
}
