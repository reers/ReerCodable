@testable import ReerCodable
import Testing
import Foundation

// MARK: - Test Models for PropertyList Coding

// Basic model with @CodingKey, @EncodingKey, @FlexibleType, @CodingIgnored
@Codable
struct PlistPerson {
    @CodingKey("user_name")
    var name: String
    
    @CodingKey("user_age")
    @EncodingKey("age")
    var age: Int
    
    @FlexibleType
    var score: Double
    
    @CodingIgnored
    var ignored: String = "should be ignored"
}

// Model with @Base64Coding
@Codable
struct PlistDataModel {
    @Base64Coding
    var data: Data?
    
    var message: String
}

// Model with @CompactDecoding
@Codable
struct PlistCompactModel: Equatable {
    @CompactDecoding
    var items: [Int]
    
    @CompactDecoding
    var names: [String]
}

@Codable
struct PlistCompactItem: Equatable {
    var id: Int
}

@Codable
struct PlistCompactModelWithObjects: Equatable {
    @CompactDecoding
    var objects: [PlistCompactItem]
}

// Model with @DateCoding
@Codable
struct PlistDateModel {
    @DateCoding(.timeIntervalSince1970)
    var date1: Date
    
    @DateCoding(.secondsSince1970)
    var date2: Date
    
    @DateCoding(.millisecondsSince1970)
    var date3: Date
}

// Model with @DefaultValue
@Codable
struct PlistDefaultModel: Equatable {
    @DecodingDefault(100)
    var count: Int
    
    @DecodingDefault("default_name")
    var name: String
}

// Model with @Flat
@Codable
struct PlistAddress {
    var city: String
    var country: String
}

@Codable
struct PlistFlatModel {
    var name: String
    
    @FlatCoding
    var address: PlistAddress
}

// Model with @SnakeCase naming convention
@Codable
@SnakeCase
struct PlistSnakeCaseModel {
    var firstName: String
    var lastName: String
}

// Model with @CodingContainer
@Codable
@CodingContainer("result.data")
struct PlistContainerModel {
    var id: Int
    var value: String
}

// Enum models
@Codable
enum PlistGender {
    case male, female
}

@Codable
enum PlistStatus: Int {
    case pending = 0
    case active = 1
    case inactive = 2
}

@Codable
enum PlistType: String {
    case typeA = "A"
    case typeB = "B"
    case typeC = "C"
}

@Codable
struct PlistEnumModel {
    var gender: PlistGender
    var status: PlistStatus
    var type: PlistType
}

// Generic model
@Codable
struct PlistResponse<T: Codable> {
    var code: Int
    var data: T?
}

@Codable
struct PlistItem: Equatable {
    var id: Int
    var name: String
}

// Model with @CustomCoding
struct DoubleMultiplier: CodingCustomizable {
    typealias Value = Double
    
    static func decode(by decoder: any Decoder, keys: [String]) throws -> Value {
        let temp: Double = try decoder.value(forKeys: keys)
        return temp * 2
    }
    
    static func encode(by encoder: any Encoder, key: String, value: Value) throws {
        try encoder.set(value / 2, forKey: key)
    }
}

@Codable
struct PlistCustomCodingModel {
    @CustomCoding(DoubleMultiplier.self)
    var multiplied: Double
}

// MARK: - PropertyList Coding Tests

struct PropertyListCodingTests {
    
    // MARK: - Basic Tests
    
    @Test
    func basicCodingKeyAndFlexibleType() throws {
        let dict: [String: Any] = [
            "user_name": "Phoenix",
            "user_age": 30,
            "score": "95.5" // String to test FlexibleType
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistPerson.self, from: plistData)
        #expect(model.name == "Phoenix")
        #expect(model.age == 30)
        #expect(model.score == 95.5)
        #expect(model.ignored == "should be ignored")
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("user_name") == "Phoenix")
        #expect(encodedDict?.int("age") == 30) // EncodingKey changes the key
        #expect(encodedDict?.double("score") == 95.5)
        #expect(encodedDict?["ignored"] == nil) // Should be ignored
    }
    
    @Test
    func base64Coding() throws {
        let originalString = "Hello PropertyList"
        let base64String = Data(originalString.utf8).base64EncodedString()
        
        let dict: [String: Any] = [
            "data": base64String,
            "message": "Test Message"
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistDataModel.self, from: plistData)
        #expect(String(data: model.data ?? Data(), encoding: .utf8) == originalString)
        #expect(model.message == "Test Message")
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("data") == base64String)
    }
    
    @Test
    func compactDecoding() throws {
        // CompactDecoding should filter out invalid items (type mismatch)
        // Note: PropertyList doesn't support null values like JSON,
        // but CompactDecoding can still filter out type-mismatched items
        let dict: [String: Any] = [
            "items": [1, "invalid", 2, 3.5, 3, ["nested": "dict"], 4, 5], // Mixed types, should filter non-Int
            "names": ["Alice", 123, "Bob", true, "Charlie"] // Mixed types, should filter non-String
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode - invalid type items should be filtered out
        let model = try PropertyListDecoder().decode(PlistCompactModel.self, from: plistData)
        #expect(model.items == [1, 2, 3, 4, 5])
        #expect(model.names == ["Alice", "Bob", "Charlie"])
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?["items"] as? [Int] == [1, 2, 3, 4, 5])
        #expect(encodedDict?["names"] as? [String] == ["Alice", "Bob", "Charlie"])
    }
    
    @Test
    func compactDecodingWithObjects() throws {
        // Test CompactDecoding with object arrays - filter out invalid objects
        let dict: [String: Any] = [
            "objects": [
                ["id": 1],
                ["invalid_key": "no id field"], // Invalid: missing "id" field
                ["id": 2],
                ["id": "not_an_int"], // Invalid: "id" is not an Int
                ["id": 3]
            ]
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode - invalid objects should be filtered out
        let model = try PropertyListDecoder().decode(PlistCompactModelWithObjects.self, from: plistData)
        #expect(model.objects.count == 3)
        #expect(model.objects == [
            PlistCompactItem(id: 1),
            PlistCompactItem(id: 2),
            PlistCompactItem(id: 3)
        ])
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        let objects = encodedDict?["objects"] as? [[String: Any]]
        #expect(objects?.count == 3)
        #expect(objects?[0].int("id") == 1)
        #expect(objects?[1].int("id") == 2)
        #expect(objects?[2].int("id") == 3)
    }
    
    @Test
    func dateCoding() throws {
        let timestamp: TimeInterval = 1700000000
        let dict: [String: Any] = [
            "date1": timestamp,
            "date2": Int(timestamp),
            "date3": Int(timestamp * 1000)
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistDateModel.self, from: plistData)
        #expect(model.date1.timeIntervalSince1970 == timestamp)
        #expect(model.date2.timeIntervalSince1970 == timestamp)
        #expect(model.date3.timeIntervalSince1970 == timestamp)
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.double("date1") == timestamp)
        #expect(encodedDict?.int("date2") == Int(timestamp))
        #expect(encodedDict?.double("date3") == timestamp * 1000)
    }
    
    @Test
    func defaultValue() throws {
        // Empty dict to test default values
        let dict: [String: Any] = [:]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistDefaultModel.self, from: plistData)
        #expect(model.count == 100)
        #expect(model.name == "default_name")
        
        // With actual values
        let dictWithValues: [String: Any] = [
            "count": 50,
            "name": "actual_name"
        ]
        let plistData2 = try PropertyListSerialization.data(fromPropertyList: dictWithValues, format: .binary, options: 0)
        let model2 = try PropertyListDecoder().decode(PlistDefaultModel.self, from: plistData2)
        #expect(model2.count == 50)
        #expect(model2.name == "actual_name")
    }
    
    @Test
    func flatCoding() throws {
        let dict: [String: Any] = [
            "name": "John",
            "city": "Beijing",
            "country": "China"
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistFlatModel.self, from: plistData)
        #expect(model.name == "John")
        #expect(model.address.city == "Beijing")
        #expect(model.address.country == "China")
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("name") == "John")
        #expect(encodedDict?.string("city") == "Beijing")
        #expect(encodedDict?.string("country") == "China")
    }
    
    @Test
    func snakeCaseNaming() throws {
        let dict: [String: Any] = [
            "first_name": "John",
            "last_name": "Doe"
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistSnakeCaseModel.self, from: plistData)
        #expect(model.firstName == "John")
        #expect(model.lastName == "Doe")
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("first_name") == "John")
        #expect(encodedDict?.string("last_name") == "Doe")
    }
    
    @Test
    func codingContainer() throws {
        let dict: [String: Any] = [
            "result": [
                "data": [
                    "id": 42,
                    "value": "test_value"
                ]
            ]
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistContainerModel.self, from: plistData)
        #expect(model.id == 42)
        #expect(model.value == "test_value")
    }
    
    @Test
    func enumCoding() throws {
        let dict: [String: Any] = [
            "gender": "male",
            "status": 1,
            "type": "B"
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistEnumModel.self, from: plistData)
        #expect(model.gender == .male)
        #expect(model.status == .active)
        #expect(model.type == .typeB)
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("gender") == "male")
        #expect(encodedDict?.int("status") == 1)
        #expect(encodedDict?.string("type") == "B")
    }
    
    @Test
    func genericType() throws {
        let dict: [String: Any] = [
            "code": 200,
            "data": [
                "id": 1,
                "name": "Test Item"
            ]
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode
        let model = try PropertyListDecoder().decode(PlistResponse<PlistItem>.self, from: plistData)
        #expect(model.code == 200)
        #expect(model.data?.id == 1)
        #expect(model.data?.name == "Test Item")
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.int("code") == 200)
        let dataDict = encodedDict?["data"] as? [String: Any]
        #expect(dataDict?.int("id") == 1)
        #expect(dataDict?.string("name") == "Test Item")
    }
    
    @Test
    func customCoding() throws {
        let dict: [String: Any] = [
            "multiplied": 50.0
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        // Decode (value should be doubled)
        let model = try PropertyListDecoder().decode(PlistCustomCodingModel.self, from: plistData)
        #expect(model.multiplied == 100.0)
        
        // Encode (value should be halved)
        let encodedData = try PropertyListEncoder().encode(model)
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.double("multiplied") == 50.0)
    }
    
    @Test
    func arrayDecoding() throws {
        let array: [[String: Any]] = [
            ["id": 1, "name": "Item 1"],
            ["id": 2, "name": "Item 2"],
            ["id": 3, "name": "Item 3"]
        ]
        let plistData = try PropertyListSerialization.data(fromPropertyList: array, format: .binary, options: 0)
        
        // Decode
        let models = try PropertyListDecoder().decode([PlistItem].self, from: plistData)
        #expect(models.count == 3)
        #expect(models[0] == PlistItem(id: 1, name: "Item 1"))
        #expect(models[1] == PlistItem(id: 2, name: "Item 2"))
        #expect(models[2] == PlistItem(id: 3, name: "Item 3"))
        
        // Encode
        let encodedData = try PropertyListEncoder().encode(models)
        let encodedArray = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [[String: Any]]
        #expect(encodedArray?.count == 3)
        #expect(encodedArray?[0].int("id") == 1)
        #expect(encodedArray?[1].string("name") == "Item 2")
    }
    
    @Test
    func xmlFormat() throws {
        let dict: [String: Any] = [
            "user_name": "XMLUser",
            "user_age": 25,
            "score": 88.5
        ]
        
        // Test with XML format
        let xmlData = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        
        // Decode from XML
        let model = try PropertyListDecoder().decode(PlistPerson.self, from: xmlData)
        #expect(model.name == "XMLUser")
        #expect(model.age == 25)
        #expect(model.score == 88.5)
        
        // Encode to XML
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let encodedData = try encoder.encode(model)
        
        // Verify it's valid XML
        let encodedDict = try PropertyListSerialization.propertyList(from: encodedData, format: nil) as? [String: Any]
        #expect(encodedDict?.string("user_name") == "XMLUser")
    }
}

