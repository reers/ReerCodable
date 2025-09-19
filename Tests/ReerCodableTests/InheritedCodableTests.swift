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

@Codable
@SnakeCase
class Vehicle {
    var brandName: String
    var modelYear: Int
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedCodable
@SnakeCase
class ElectricCar: Vehicle {
    var batteryCapacity: Double
    var chargingPort: String
}

let jsonDataElectricCar = """
{
    "brand_name": "Tesla",
    "model_year": 2023,
    "battery_capacity": 75.5,
    "charging_port": "Type 2"
}
""".data(using: .utf8)!


@Codable
@FlexibleType
class FlexiblePet {
    var age: Int
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedDecodable
@FlexibleType
class FlexibleDog: FlexiblePet {
    var isMale: Bool
}


extension TestReerCodable {

    @Test("Inherited Decodable Only")
    func inheritedDecodableOnly() throws {
        let decoder = JSONDecoder()

        let model = try decoder.decode(DogForDecodableTest.self, from: jsonDataDog)

        #expect(model.name == "Buddy")
        #expect(model.breed == "Golden Retriever")

        let encoder = JSONEncoder()
        _ = try encoder.encode(model)
        print("Successfully encoded DogForDecodableTest instance.")
    }
    
    @Test("InheritedCodable with SnakeCase")
    func inheritedCodableWithSnakeCase() throws {
        let decoder = JSONDecoder()
        let model = try decoder.decode(ElectricCar.self, from: jsonDataElectricCar)
        
        #expect(model.brandName == "Tesla")
        #expect(model.modelYear == 2023)
        #expect(model.batteryCapacity == 75.5)
        #expect(model.chargingPort == "Type 2")
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(model)
        let dict = encodedData.stringAnyDictionary
        
        #expect(dict?.keys.contains("brand_name") == true)
        #expect(dict?.keys.contains("model_year") == true)
        #expect(dict?.keys.contains("battery_capacity") == true)
        #expect(dict?.keys.contains("charging_port") == true)
        #expect(dict.string("brand_name") == "Tesla")
        #expect(dict.int("model_year") == 2023)
        #expect(dict.double("battery_capacity") == 75.5)
        #expect(dict.string("charging_port") == "Type 2")
    }
    
    @Test("InheritedDecodable with FlexibleType")
    func inheritedDecodableWithFlexibleType() throws {
        let decoder = JSONDecoder()
        
        let jsonString = """
        {
            "age": "3",
            "isMale": 1
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        let model = try decoder.decode(FlexibleDog.self, from: jsonData)
        
        #expect(model.age == 3)
        #expect(model.isMale == true)
    }
}
