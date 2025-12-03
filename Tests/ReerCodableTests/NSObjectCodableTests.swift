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

// MARK: - Inherited from NSObject Subclass

/// Base class: NSObject -> Article
@Codable
class Article: NSObject {
    let title: String
    var content: String = ""
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

/// Subclass: NSObject -> Article -> NewsArticle
@InheritedCodable
class NewsArticle: Article {
    let source: String
    var publishDate: String = ""
    
    override func didDecode(from decoder: any Decoder) throws {
        try super.didDecode(from: decoder)
    }
    
    override func willEncode(to encoder: any Encoder) throws {
        try super.willEncode(to: encoder)
    }
}

/// Third level: NSObject -> Article -> NewsArticle -> BreakingNews
@InheritedCodable
class BreakingNews: NewsArticle {
    let priority: Int
    var isUrgent: Bool = false
}

// MARK: - Inherited NSObject with SnakeCase

@Codable
@SnakeCase
class BaseProduct: NSObject {
    let productId: String
    var productName: String = ""
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedCodable
@SnakeCase
class ElectronicProduct: BaseProduct {
    let brandName: String
    var warrantyYears: Int = 1
}

// MARK: - Inherited NSObject with FlexibleType

@Codable
@FlexibleType
class BaseEntity: NSObject {
    let entityId: Int
    var isActive: Bool = true
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedDecodable
@FlexibleType
class UserEntity: BaseEntity {
    let userId: Int
    var verified: Bool = false
}

// MARK: - Inherited NSObject with CodingKey

@Codable
class BaseRecord: NSObject {
    @CodingKey("record_id")
    let recordId: String
    
    var createdAt: String = ""
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedCodable
class DetailedRecord: BaseRecord {
    @CodingKey("record_type")
    let recordType: String
    
    @CodingKey("extra_info.note")
    var note: String = ""
}

// MARK: - NSObject with @objc attribute (OC compatible)

@Codable
@objc
class ObjCCompatibleModel: NSObject {
    @objc let identifier: String
    @objc var displayName: String = ""
    @objc let count: Int
}

// MARK: - NSObject with @objcMembers (all members exposed to OC)

@Codable
@objcMembers
class ObjCMembersModel: NSObject {
    let userId: String
    var userName: String = ""
    let age: Int
    var isVIP: Bool = false
}

// MARK: - NSObject with @objcMembers and CodingKey

@Codable
@objcMembers
@SnakeCase
class ObjCMembersWithSnakeCase: NSObject {
    let productId: String
    var productName: String = ""
    let stockCount: Int
}

// MARK: - NSObject with dynamic (for KVO support)

@Codable
@objcMembers
class KVOCompatibleModel: NSObject {
    let modelId: String
    @objc dynamic var observableValue: String = ""
    @objc dynamic var observableCount: Int = 0
}

// MARK: - NSObject with @objcMembers and FlexibleType

@Codable
@objcMembers
@FlexibleType
class ObjCMembersWithFlexibleType: NSObject {
    let itemId: Int
    var quantity: Int = 0
    let isAvailable: Bool
}

// MARK: - Inherited NSObject with @objcMembers

@Codable
@objcMembers
class ObjCBaseEntity: NSObject {
    let entityId: String
    var entityName: String = ""
    
    func didDecode(from decoder: any Decoder) throws {}
    func willEncode(to encoder: any Encoder) throws {}
}

@InheritedCodable
@objcMembers
class ObjCDerivedEntity: ObjCBaseEntity {
    let derivedId: String
    @objc dynamic var observableStatus: String = ""
}

// MARK: - NSObject with @objcMembers, CodingKey and Nested Key

@Codable
@objcMembers
class ObjCMembersWithCodingKey: NSObject {
    @CodingKey("user_id")
    let userId: String
    
    @CodingKey("profile.nickname")
    var nickname: String = ""
    
    @CodingKey("profile.avatar_url")
    let avatarUrl: String
}

// MARK: - NSObject with @objcMembers and CodingIgnored

@Codable
@objcMembers
class ObjCMembersWithIgnored: NSObject {
    let name: String
    
    @CodingIgnored
    @objc dynamic var cachedValue: String = "cache_default"
    
    var score: Int = 0
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
    
    // MARK: - Inherited NSObject Tests
    
    @Test("Inherited NSObject - Basic Inheritance")
    func inheritedNSObjectBasic() throws {
        let dict: [String: Any] = [
            "title": "Breaking News",
            "content": "Something happened",
            "source": "CNN",
            "publishDate": "2024-01-01"
        ]
        
        // Decode
        let model = try NewsArticle.decoded(from: dict)
        #expect(model.title == "Breaking News")
        #expect(model.content == "Something happened")
        #expect(model.source == "CNN")
        #expect(model.publishDate == "2024-01-01")
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("title") == "Breaking News")
        #expect(encoded.string("content") == "Something happened")
        #expect(encoded.string("source") == "CNN")
        #expect(encoded.string("publishDate") == "2024-01-01")
    }
    
    @Test("Inherited NSObject - Three Level Inheritance")
    func inheritedNSObjectThreeLevel() throws {
        let jsonData = """
        {
            "title": "Earthquake Alert",
            "content": "Major earthquake detected",
            "source": "USGS",
            "publishDate": "2024-03-15",
            "priority": 1,
            "isUrgent": true
        }
        """.data(using: .utf8)!
        
        // Decode
        let model = try JSONDecoder().decode(BreakingNews.self, from: jsonData)
        #expect(model.title == "Earthquake Alert")
        #expect(model.content == "Major earthquake detected")
        #expect(model.source == "USGS")
        #expect(model.publishDate == "2024-03-15")
        #expect(model.priority == 1)
        #expect(model.isUrgent == true)
        
        // Encode
        let encodedData = try JSONEncoder().encode(model)
        let dict = encodedData.stringAnyDictionary
        #expect(dict.string("title") == "Earthquake Alert")
        #expect(dict.string("source") == "USGS")
        #expect(dict.int("priority") == 1)
        #expect(dict.bool("isUrgent") == true)
    }
    
    @Test("Inherited NSObject - With SnakeCase")
    func inheritedNSObjectWithSnakeCase() throws {
        let dict: [String: Any] = [
            "product_id": "SKU-12345",
            "product_name": "iPhone 15",
            "brand_name": "Apple",
            "warranty_years": 2
        ]
        
        // Decode
        let model = try ElectronicProduct.decoded(from: dict)
        #expect(model.productId == "SKU-12345")
        #expect(model.productName == "iPhone 15")
        #expect(model.brandName == "Apple")
        #expect(model.warrantyYears == 2)
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("product_id") == "SKU-12345")
        #expect(encoded.string("product_name") == "iPhone 15")
        #expect(encoded.string("brand_name") == "Apple")
        #expect(encoded.int("warranty_years") == 2)
    }
    
    @Test("Inherited NSObject - With FlexibleType")
    func inheritedNSObjectWithFlexibleType() throws {
        let dict: [String: Any] = [
            "entityId": "999",      // String instead of Int
            "isActive": 1,          // Int instead of Bool
            "userId": "12345",      // String instead of Int
            "verified": "true"      // String instead of Bool
        ]
        
        // Decode with type conversion
        let model = try UserEntity.decoded(from: dict)
        #expect(model.entityId == 999)
        #expect(model.isActive == true)
        #expect(model.userId == 12345)
        #expect(model.verified == true)
    }
    
    @Test("Inherited NSObject - With CodingKey")
    func inheritedNSObjectWithCodingKey() throws {
        let dict: [String: Any] = [
            "record_id": "REC-001",
            "createdAt": "2024-01-01",
            "record_type": "invoice",
            "extra_info": [
                "note": "Important record"
            ]
        ]
        
        // Decode
        let model = try DetailedRecord.decoded(from: dict)
        #expect(model.recordId == "REC-001")
        #expect(model.createdAt == "2024-01-01")
        #expect(model.recordType == "invoice")
        #expect(model.note == "Important record")
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("record_id") == "REC-001")
        #expect(encoded.string("record_type") == "invoice")
    }
    
    @Test("Inherited NSObject - Partial Data with Defaults")
    func inheritedNSObjectPartialData() throws {
        // Only provide required fields, let defaults fill in
        let dict: [String: Any] = [
            "title": "Simple Article",
            "source": "Local News"
        ]
        
        let model = try NewsArticle.decoded(from: dict)
        #expect(model.title == "Simple Article")
        #expect(model.content == "")  // Default value
        #expect(model.source == "Local News")
        #expect(model.publishDate == "")  // Default value
    }
    
    @Test("Inherited NSObject - Base Class Only")
    func inheritedNSObjectBaseClass() throws {
        let dict: [String: Any] = [
            "title": "Base Article",
            "content": "Base content only"
        ]
        
        // Test that base class works independently
        let model = try Article.decoded(from: dict)
        #expect(model.title == "Base Article")
        #expect(model.content == "Base content only")
        
        let encoded = try model.encodedDict()
        #expect(encoded.string("title") == "Base Article")
        #expect(encoded.string("content") == "Base content only")
    }
    
    // MARK: - @objc and @objcMembers Tests
    
    @Test("NSObject with @objc attribute")
    func nsObjectWithObjcAttribute() throws {
        let dict: [String: Any] = [
            "identifier": "OBJ-001",
            "displayName": "Test Object",
            "count": 42
        ]
        
        // Decode
        let model = try ObjCCompatibleModel.decoded(from: dict)
        #expect(model.identifier == "OBJ-001")
        #expect(model.displayName == "Test Object")
        #expect(model.count == 42)
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("identifier") == "OBJ-001")
        #expect(encoded.string("displayName") == "Test Object")
        #expect(encoded.int("count") == 42)
        
        // Verify OC runtime accessibility
        #expect(model.responds(to: #selector(getter: ObjCCompatibleModel.identifier)))
        #expect(model.responds(to: #selector(getter: ObjCCompatibleModel.displayName)))
    }
    
    @Test("NSObject with @objcMembers")
    func nsObjectWithObjcMembers() throws {
        let dict: [String: Any] = [
            "userId": "USER-12345",
            "userName": "Phoenix",
            "age": 28,
            "isVIP": true
        ]
        
        // Decode
        let model = try ObjCMembersModel.decoded(from: dict)
        #expect(model.userId == "USER-12345")
        #expect(model.userName == "Phoenix")
        #expect(model.age == 28)
        #expect(model.isVIP == true)
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("userId") == "USER-12345")
        #expect(encoded.string("userName") == "Phoenix")
        #expect(encoded.int("age") == 28)
        #expect(encoded.bool("isVIP") == true)
        
        // Verify all members are accessible via OC runtime
        #expect(model.responds(to: #selector(getter: ObjCMembersModel.userId)))
        #expect(model.responds(to: #selector(getter: ObjCMembersModel.userName)))
        #expect(model.responds(to: #selector(getter: ObjCMembersModel.age)))
    }
    
    @Test("NSObject with @objcMembers and SnakeCase")
    func nsObjectWithObjcMembersAndSnakeCase() throws {
        let dict: [String: Any] = [
            "product_id": "PROD-999",
            "product_name": "MacBook Pro",
            "stock_count": 100
        ]
        
        // Decode
        let model = try ObjCMembersWithSnakeCase.decoded(from: dict)
        #expect(model.productId == "PROD-999")
        #expect(model.productName == "MacBook Pro")
        #expect(model.stockCount == 100)
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("product_id") == "PROD-999")
        #expect(encoded.string("product_name") == "MacBook Pro")
        #expect(encoded.int("stock_count") == 100)
    }
    
    @Test("NSObject with dynamic for KVO")
    func nsObjectWithDynamicForKVO() throws {
        let dict: [String: Any] = [
            "modelId": "KVO-001",
            "observableValue": "initial",
            "observableCount": 10
        ]
        
        // Decode
        let model = try KVOCompatibleModel.decoded(from: dict)
        #expect(model.modelId == "KVO-001")
        #expect(model.observableValue == "initial")
        #expect(model.observableCount == 10)
        
        // Test KVO capability - dynamic properties can be observed
        var observedValue: String?
        let observation = model.observe(\.observableValue, options: [.new]) { _, change in
            observedValue = change.newValue
        }
        
        // Modify the dynamic property
        model.observableValue = "changed"
        #expect(observedValue == "changed")
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("modelId") == "KVO-001")
        #expect(encoded.string("observableValue") == "changed")
        
        // Clean up observation
        observation.invalidate()
    }
    
    @Test("NSObject with @objcMembers and FlexibleType")
    func nsObjectWithObjcMembersAndFlexibleType() throws {
        let dict: [String: Any] = [
            "itemId": "999",        // String instead of Int
            "quantity": "50",       // String instead of Int
            "isAvailable": 1        // Int instead of Bool
        ]
        
        // Decode with type conversion
        let model = try ObjCMembersWithFlexibleType.decoded(from: dict)
        #expect(model.itemId == 999)
        #expect(model.quantity == 50)
        #expect(model.isAvailable == true)
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.int("itemId") == 999)
        #expect(encoded.int("quantity") == 50)
        #expect(encoded.bool("isAvailable") == true)
    }
    
    @Test("Inherited NSObject with @objcMembers")
    func inheritedNSObjectWithObjcMembers() throws {
        let dict: [String: Any] = [
            "entityId": "ENT-001",
            "entityName": "Base Entity",
            "derivedId": "DRV-001",
            "observableStatus": "active"
        ]
        
        // Decode
        let model = try ObjCDerivedEntity.decoded(from: dict)
        #expect(model.entityId == "ENT-001")
        #expect(model.entityName == "Base Entity")
        #expect(model.derivedId == "DRV-001")
        #expect(model.observableStatus == "active")
        
        // Test KVO on derived class dynamic property
        var observedStatus: String?
        let observation = model.observe(\.observableStatus, options: [.new]) { _, change in
            observedStatus = change.newValue
        }
        
        model.observableStatus = "inactive"
        #expect(observedStatus == "inactive")
        
        // Encode
        let encoded = try model.encodedDict()
        #expect(encoded.string("entityId") == "ENT-001")
        #expect(encoded.string("derivedId") == "DRV-001")
        #expect(encoded.string("observableStatus") == "inactive")
        
        observation.invalidate()
    }
    
    @Test("NSObject with @objcMembers and CodingKey")
    func nsObjectWithObjcMembersAndCodingKey() throws {
        let dict: [String: Any] = [
            "user_id": "UID-12345",
            "profile": [
                "nickname": "小明",
                "avatar_url": "https://example.com/avatar.png"
            ]
        ]
        
        // Decode
        let model = try ObjCMembersWithCodingKey.decoded(from: dict)
        #expect(model.userId == "UID-12345")
        #expect(model.nickname == "小明")
        #expect(model.avatarUrl == "https://example.com/avatar.png")
        
        // Verify OC runtime accessibility
        #expect(model.responds(to: #selector(getter: ObjCMembersWithCodingKey.userId)))
        #expect(model.responds(to: #selector(getter: ObjCMembersWithCodingKey.nickname)))
    }
    
    @Test("NSObject with @objcMembers and CodingIgnored")
    func nsObjectWithObjcMembersAndCodingIgnored() throws {
        let dict: [String: Any] = [
            "name": "Test Name",
            "cachedValue": "should be ignored",
            "score": 95
        ]
        
        // Decode
        let model = try ObjCMembersWithIgnored.decoded(from: dict)
        #expect(model.name == "Test Name")
        #expect(model.cachedValue == "cache_default")  // Should use default, not decoded value
        #expect(model.score == 95)
        
        // Test KVO on ignored dynamic property
        var observedCache: String?
        let observation = model.observe(\.cachedValue, options: [.new]) { _, change in
            observedCache = change.newValue
        }
        
        model.cachedValue = "new_cache"
        #expect(observedCache == "new_cache")
        
        // Encode - cachedValue should not be included
        let encoded = try model.encodedDict()
        #expect(encoded.string("name") == "Test Name")
        #expect(encoded.int("score") == 95)
        #expect(encoded["cachedValue"] == nil)  // Should not be encoded
        
        observation.invalidate()
    }
    
    @Test("NSObject with @objcMembers JSON round trip")
    func nsObjectWithObjcMembersJSONRoundTrip() throws {
        let jsonData = """
        {
            "userId": "JSON-USER-001",
            "userName": "JSON User",
            "age": 35,
            "isVIP": false
        }
        """.data(using: .utf8)!
        
        // Decode from JSON
        let model = try JSONDecoder().decode(ObjCMembersModel.self, from: jsonData)
        #expect(model.userId == "JSON-USER-001")
        #expect(model.userName == "JSON User")
        #expect(model.age == 35)
        #expect(model.isVIP == false)
        
        // Encode back to JSON
        let encodedData = try JSONEncoder().encode(model)
        let dict = encodedData.stringAnyDictionary
        #expect(dict.string("userId") == "JSON-USER-001")
        #expect(dict.string("userName") == "JSON User")
        #expect(dict.int("age") == 35)
        #expect(dict.bool("isVIP") == false)
    }
    
    @Test("NSObject with @objcMembers memberwise init")
    func nsObjectWithObjcMembersMemberwiseInit() throws {
        // Test memberwise init works with @objcMembers
        let model = ObjCMembersModel(userId: "INIT-001", userName: "Init User", age: 30, isVIP: true)
        #expect(model.userId == "INIT-001")
        #expect(model.userName == "Init User")
        #expect(model.age == 30)
        #expect(model.isVIP == true)
        
        // Encode to verify
        let encoded = try model.encodedDict()
        #expect(encoded.string("userId") == "INIT-001")
        #expect(encoded.bool("isVIP") == true)
    }
}


