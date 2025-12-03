@testable import ReerCodable
import Testing
import Foundation

// MARK: - Basic NSObject Subclass (let properties without default values)

@Codable
public class Message: NSObject {
    let title: String
    let type: String
}

// MARK: - NSObject Subclass with Optional Properties (mixed let/var)

@Codable
class NSObjectWithOptional: NSObject {
    let name: String
    var age: Int?
    let score: Double
}

// MARK: - NSObject Subclass with CodingKey (let properties)

@Codable
class NSObjectWithCodingKey: NSObject {
    @CodingKey("user_name")
    let name: String
    
    @CodingKey("user_age")
    let age: Int
}

// MARK: - NSObject Subclass with Nested Key (let properties)

@Codable
class NSObjectWithNestedKey: NSObject {
    let name: String
    
    @CodingKey("info.address")
    let address: String
}

// MARK: - NSObject Subclass with FlexibleType (let properties)

@Codable
@FlexibleType
class NSObjectWithFlexibleType: NSObject {
    let id: Int
    let isActive: Bool
}

// MARK: - NSObject Subclass with Base64Coding (mixed let/var)

@Codable
class NSObjectWithBase64: NSObject {
    let name: String
    
    @Base64Coding
    var data: Data?
}

// MARK: - NSObject Subclass with CodingIgnored

@Codable
class NSObjectWithIgnored: NSObject {
    let name: String
    
    @CodingIgnored
    var ignoredField: String = "default"
}

// MARK: - NSObject Subclass with SnakeCase (let properties)

@Codable
@SnakeCase
class NSObjectWithSnakeCase: NSObject {
    let userName: String
    let userAge: Int
}

// MARK: - NSObject Subclass with ReerCodableDelegate (mixed let/var for delegate test)

@Codable
class NSObjectWithDelegate: NSObject {
    let value: Int
    var processed: Bool = false
    
    func didDecode(from decoder: any Decoder) throws {
        processed = true
    }
}

// MARK: - NSObject Subclass with default values and let

@Codable
class NSObjectWithDefaults: NSObject {
    let id: Int
    var name: String = "default_name"
    let isEnabled: Bool
}

// MARK: - Tests

extension TestReerCodable {
    
    @Test("Basic NSObject Subclass Decoding")
    func basicNSObjectDecoding() throws {
        let dict: [String: Any] = [
            "title": "Hello World",
            "type": "article"
        ]
        
        let model = try Message.decoded(from: dict)
        #expect(model.title == "Hello World")
        #expect(model.type == "article")
    }
    
    @Test("Basic NSObject Subclass Encoding")
    func basicNSObjectEncoding() throws {
        let model = Message(title: "Test Title", type: "news")
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("title") == "Test Title")
        #expect(encoded.string("type") == "news")
    }
    
    @Test("NSObject with Optional Properties")
    func nsObjectWithOptionalProperties() throws {
        let dict: [String: Any] = [
            "name": "Phoenix",
            "score": 95.5
            // age is not provided
        ]
        
        let model = try NSObjectWithOptional.decoded(from: dict)
        #expect(model.name == "Phoenix")
        #expect(model.age == nil)
        #expect(model.score == 95.5)
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("name") == "Phoenix")
        #expect(encoded.double("score") == 95.5)
    }
    
    @Test("NSObject with CodingKey")
    func nsObjectWithCodingKey() throws {
        let dict: [String: Any] = [
            "user_name": "Phoenix",
            "user_age": 30
        ]
        
        let model = try NSObjectWithCodingKey.decoded(from: dict)
        #expect(model.name == "Phoenix")
        #expect(model.age == 30)
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("user_name") == "Phoenix")
        #expect(encoded.int("user_age") == 30)
    }
    
    @Test("NSObject with Nested Key")
    func nsObjectWithNestedKey() throws {
        let dict: [String: Any] = [
            "name": "Phoenix",
            "info": [
                "address": "Beijing"
            ]
        ]
        
        let model = try NSObjectWithNestedKey.decoded(from: dict)
        #expect(model.name == "Phoenix")
        #expect(model.address == "Beijing")
    }
    
    @Test("NSObject with FlexibleType")
    func nsObjectWithFlexibleType() throws {
        let dict: [String: Any] = [
            "id": "123",  // String instead of Int
            "isActive": 1  // Int instead of Bool
        ]
        
        let model = try NSObjectWithFlexibleType.decoded(from: dict)
        #expect(model.id == 123)
        #expect(model.isActive == true)
    }
    
    @Test("NSObject with Base64Coding")
    func nsObjectWithBase64Coding() throws {
        let dict: [String: Any] = [
            "name": "Test",
            "data": "aGVsbG8gd29ybGQ="  // "hello world" in base64
        ]
        
        let model = try NSObjectWithBase64.decoded(from: dict)
        #expect(model.name == "Test")
        #expect(model.data?.utf8String == "hello world")
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("data") == "aGVsbG8gd29ybGQ=")
    }
    
    @Test("NSObject with CodingIgnored")
    func nsObjectWithCodingIgnored() throws {
        let dict: [String: Any] = [
            "name": "Phoenix",
            "ignoredField": "should be ignored"
        ]
        
        let model = try NSObjectWithIgnored.decoded(from: dict)
        #expect(model.name == "Phoenix")
        #expect(model.ignoredField == "default")  // Should use default value
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("name") == "Phoenix")
        #expect(encoded["ignoredField"] == nil)  // Should not be encoded
    }
    
    @Test("NSObject with SnakeCase")
    func nsObjectWithSnakeCase() throws {
        let dict: [String: Any] = [
            "user_name": "Phoenix",
            "user_age": 30
        ]
        
        let model = try NSObjectWithSnakeCase.decoded(from: dict)
        #expect(model.userName == "Phoenix")
        #expect(model.userAge == 30)
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("user_name") == "Phoenix")
        #expect(encoded.int("user_age") == 30)
    }
    
    @Test("NSObject with Delegate Methods")
    func nsObjectWithDelegateMethods() throws {
        let dict: [String: Any] = [
            "value": 10,
            "processed": false
        ]
        
        // Test didDecode
        let model = try NSObjectWithDelegate.decoded(from: dict)
        #expect(model.value == 10)
        #expect(model.processed == true)  // Should be set by didDecode
        
        // Test encode
        let encoded = try model.encodedDict()
        #expect(encoded.int("value") == 10)
        #expect(encoded.bool("processed") == true)
    }
    
    @Test("NSObject Membewise Init")
    func nsObjectMemberweiseInit() throws {
        // Test that membewise init works correctly
        let model = Message(title: "Init Title", type: "init_type")
        #expect(model.title == "Init Title")
        #expect(model.type == "init_type")
        
        // Encode to verify
        let encoded = try model.encodedDict()
        #expect(encoded.string("title") == "Init Title")
        #expect(encoded.string("type") == "init_type")
    }
    
    @Test("NSObject JSON Decoding")
    func nsObjectJSONDecoding() throws {
        let jsonData = """
        {
            "title": "JSON Title",
            "type": "json_type"
        }
        """.data(using: .utf8)!
        
        let model = try JSONDecoder().decode(Message.self, from: jsonData)
        #expect(model.title == "JSON Title")
        #expect(model.type == "json_type")
    }
    
    @Test("NSObject JSON Encoding")
    func nsObjectJSONEncoding() throws {
        let model = Message(title: "Encode Test", type: "encode_type")
        
        let data = try JSONEncoder().encode(model)
        let dict = data.stringAnyDictionary
        
        #expect(dict.string("title") == "Encode Test")
        #expect(dict.string("type") == "encode_type")
    }
    
    @Test("NSObject with Defaults and Let Properties")
    func nsObjectWithDefaultsAndLet() throws {
        // Test decoding with partial data (name uses default)
        let dict: [String: Any] = [
            "id": 42,
            "isEnabled": true
        ]
        
        let model = try NSObjectWithDefaults.decoded(from: dict)
        #expect(model.id == 42)
        #expect(model.name == "default_name")  // Should use default value
        #expect(model.isEnabled == true)
        
        // Test encoding
        let encoded = try model.encodedDict()
        #expect(encoded.int("id") == 42)
        #expect(encoded.string("name") == "default_name")
        #expect(encoded.bool("isEnabled") == true)
    }
    
    @Test("NSObject with Defaults Override")
    func nsObjectWithDefaultsOverride() throws {
        // Test decoding with full data (overrides default)
        let dict: [String: Any] = [
            "id": 100,
            "name": "custom_name",
            "isEnabled": false
        ]
        
        let model = try NSObjectWithDefaults.decoded(from: dict)
        #expect(model.id == 100)
        #expect(model.name == "custom_name")  // Should override default
        #expect(model.isEnabled == false)
    }
    
    @Test("NSObject Memberwise Init with Let Properties")
    func nsObjectMemberweiseInitWithLet() throws {
        // Test memberwise init with let properties (no default values)
        let model = NSObjectWithCodingKey(name: "Test User", age: 25)
        #expect(model.name == "Test User")
        #expect(model.age == 25)
        
        // Encode to verify
        let encoded = try model.encodedDict()
        #expect(encoded.string("user_name") == "Test User")
        #expect(encoded.int("user_age") == 25)
    }
}


