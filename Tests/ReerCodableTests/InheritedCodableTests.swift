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

@Codable
class Pet {
    var name: String
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedDecodable
class DogForDecodableTest: Pet {
    var breed: String
}


// MARK: - Test Data

let jsonDataDog = """
{
    "name": "Buddy",
    "breed": "Golden Retriever"
}
""".data(using: .utf8)!

// MARK: - Test Suite Extension

extension TestReerCodable { // Assuming your test suite struct/class is named TestReerCodable

    @Test("Inherited Decodable Only")
    func inheritedDecodableOnly() throws {
        let decoder = JSONDecoder()

        // Decode using the class marked ONLY with @InheritedDecodable
        let model = try decoder.decode(DogForDecodableTest.self, from: jsonDataDog)

        // Verify properties from both base and subclass are decoded correctly
        #expect(model.name == "Buddy")
        #expect(model.breed == "Golden Retriever")

        // Optional: Verify that it can still be encoded using the base class's Encodable conformance
        let encoder = JSONEncoder()
        _ = try encoder.encode(model) // Should not throw if base conformance works
        print("Successfully encoded DogForDecodableTest instance.")
    }
}
