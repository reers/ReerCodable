@testable import ReerCodable
import Testing
import Foundation

struct TestAnyCodableJSONAccess {
    
    // Test data for JSON access functionality
    let complexJSON = AnyCodable([
        "users": [
            ["name": "Alice", "age": 25, "active": true],
            ["name": "Bob", "age": 30, "active": false],
            ["name": "Charlie", "age": 35, "active": true]
        ],
        "metadata": [
            "total": 3,
            "status": "active",
            "config": [
                "debug": true,
                "version": "1.0"
            ]
        ],
        "tags": ["swift", "json", "codable"],
        "empty_array": [],
        "empty_dict": [:]
    ])
    
    let simpleArray = AnyCodable(["apple", "banana", "cherry"])
    let simpleDict = AnyCodable(["name": "John", "age": 28, "city": "NYC"])
    
    // MARK: - Dictionary Access Tests
    
    @Test("Dictionary key access - valid keys")
    func dictionaryValidAccess() throws {
        // Test basic dictionary access
        #expect(simpleDict["name"].string == "John")
        #expect(simpleDict["age"].int == 28)
        #expect(simpleDict["city"].string == "NYC")
        
        // Test nested dictionary access
        #expect(complexJSON["metadata"]["total"].int == 3)
        #expect(complexJSON["metadata"]["status"].string == "active")
        #expect(complexJSON["metadata"]["config"]["debug"].bool == true)
        #expect(complexJSON["metadata"]["config"]["version"].string == "1.0")
    }
    
    @Test("Dictionary key access - invalid keys")
    func dictionaryInvalidAccess() throws {
        // Test non-existent keys
        #expect(simpleDict["nonexistent"].isNull == true)
        #expect(simpleDict["missing"].string == nil)
        
        // Test nested non-existent keys
        #expect(complexJSON["metadata"]["missing"].isNull == true)
        #expect(complexJSON["nonexistent"]["nested"].isNull == true)
    }
    
    // MARK: - Array Access Tests
    
    @Test("Array index access - valid indices")
    func arrayValidAccess() throws {
        // Test basic array access
        #expect(simpleArray[0].string == "apple")
        #expect(simpleArray[1].string == "banana")
        #expect(simpleArray[2].string == "cherry")
        
        // Test nested array access
        #expect(complexJSON["users"][0]["name"].string == "Alice")
        #expect(complexJSON["users"][0]["age"].int == 25)
        #expect(complexJSON["users"][0]["active"].bool == true)
        
        #expect(complexJSON["users"][1]["name"].string == "Bob")
        #expect(complexJSON["users"][1]["age"].int == 30)
        #expect(complexJSON["users"][1]["active"].bool == false)
        
        #expect(complexJSON["users"][2]["name"].string == "Charlie")
        #expect(complexJSON["users"][2]["age"].int == 35)
        #expect(complexJSON["users"][2]["active"].bool == true)
        
        #expect(complexJSON["tags"][0].string == "swift")
        #expect(complexJSON["tags"][1].string == "json")
        #expect(complexJSON["tags"][2].string == "codable")
    }
    
    @Test("Array index access - invalid indices")
    func arrayInvalidAccess() throws {
        // Test out-of-bounds access
        #expect(simpleArray[10].isNull == true)
        #expect(simpleArray[-1].isNull == true)
        #expect(simpleArray[100].string == nil)
        
        // Test nested out-of-bounds access
        #expect(complexJSON["users"][10]["name"].isNull == true)
        #expect(complexJSON["tags"][5].isNull == true)
        
        // Test access on empty arrays
        #expect(complexJSON["empty_array"][0].isNull == true)
    }
    
    // MARK: - Mixed Access Tests
    
    @Test("Mixed dictionary and array access")
    func mixedAccess() throws {
        // Test complex chained access
        #expect(complexJSON["users"][0]["name"].string == "Alice")
        #expect(complexJSON["users"][1]["age"].int == 30)
        #expect(complexJSON["users"][2]["active"].bool == true)
        
        // Test accessing array inside nested dictionary
        #expect(complexJSON["metadata"]["config"]["version"].string == "1.0")
        
        // Test mixed invalid access
        #expect(complexJSON["users"][0]["nonexistent"].isNull == true)
        #expect(complexJSON["users"][10]["name"].isNull == true)
        #expect(complexJSON["nonexistent"][0]["field"].isNull == true)
    }
    
    // MARK: - Type Safety Tests
    
    @Test("Type access on wrong types")
    func typeAccessOnWrongTypes() throws {
        // Test array access on dictionary
        #expect(simpleDict[0].isNull == true)
        #expect(complexJSON["metadata"][0].isNull == true)
        
        // Test dictionary access on array
        #expect(simpleArray["key"].isNull == true)
        #expect(complexJSON["tags"]["key"].isNull == true)
        
        // Test access on null values
        let nullValue = AnyCodable.null
        #expect(nullValue["key"].isNull == true)
        #expect(nullValue[0].isNull == true)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Empty containers access")
    func emptyContainersAccess() throws {
        // Test empty array
        #expect(complexJSON["empty_array"][0].isNull == true)
        
        // Test empty dictionary  
        #expect(complexJSON["empty_dict"]["key"].isNull == true)
        
        // Test completely empty AnyCodable
        let emptyArray = AnyCodable([])
        let emptyDict = AnyCodable([:])
        
        #expect(emptyArray[0].isNull == true)
        #expect(emptyDict["key"].isNull == true)
    }
    
    @Test("Path subscript with JSONKey protocol")
    func pathSubscriptAccess() throws {
        // Test direct path access
        #expect(complexJSON[path: "users"].array?.count == 3)
        #expect(complexJSON[path: "tags"].array?.count == 3)
        #expect(complexJSON[path: "metadata"].dict != nil)
        
        // Test path access with array indices
        let users = complexJSON[path: "users"]
        #expect(users[path: 0].dict != nil)
        #expect(users[path: 1].dict != nil)
        #expect(users[path: 2].dict != nil)
        
        let firstUser = users[path: 0]
        #expect(firstUser[path: "name"].string == "Alice")
        #expect(firstUser[path: "age"].int == 25)
    }
    
    // MARK: - Performance Boundary Tests
    
    @Test("Boundary checking performance")
    func boundaryCheckingPerformance() throws {
        let largeArray = AnyCodable(Array(0..<1000))
        
        // Test valid bounds
        #expect(largeArray[0].int == 0)
        #expect(largeArray[999].int == 999)
        
        // Test invalid bounds (should be O(1) check)
        #expect(largeArray[1000].isNull == true)
        #expect(largeArray[-1].isNull == true)
        #expect(largeArray[Int.max].isNull == true)
    }
    
    // MARK: - Real JSON Data Tests
    
    @Test("Real JSON data access")
    func realJSONDataAccess() throws {
        let jsonString = """
        {
            "api_response": {
                "status": 200,
                "data": {
                    "users": [
                        {
                            "id": 1,
                            "profile": {
                                "name": "John Doe",
                                "email": "john@example.com",
                                "preferences": {
                                    "theme": "dark",
                                    "notifications": true
                                }
                            }
                        },
                        {
                            "id": 2,
                            "profile": {
                                "name": "Jane Smith", 
                                "email": "jane@example.com",
                                "preferences": {
                                    "theme": "light",
                                    "notifications": false
                                }
                            }
                        }
                    ]
                }
            }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let anyCodable = try JSONDecoder().decode(AnyCodable.self, from: jsonData)
        
        // Test deep nested access
        #expect(anyCodable["api_response"]["status"].int == 200)
        #expect(anyCodable["api_response"]["data"]["users"][0]["id"].int == 1)
        #expect(anyCodable["api_response"]["data"]["users"][0]["profile"]["name"].string == "John Doe")
        #expect(anyCodable["api_response"]["data"]["users"][0]["profile"]["email"].string == "john@example.com")
        #expect(anyCodable["api_response"]["data"]["users"][0]["profile"]["preferences"]["theme"].string == "dark")
        #expect(anyCodable["api_response"]["data"]["users"][0]["profile"]["preferences"]["notifications"].bool == true)
        
        #expect(anyCodable["api_response"]["data"]["users"][1]["profile"]["name"].string == "Jane Smith")
        #expect(anyCodable["api_response"]["data"]["users"][1]["profile"]["preferences"]["theme"].string == "light")
        #expect(anyCodable["api_response"]["data"]["users"][1]["profile"]["preferences"]["notifications"].bool == false)
        
        // Test invalid deep access
        #expect(anyCodable["api_response"]["data"]["users"][5]["profile"]["name"].isNull == true)
        #expect(anyCodable["invalid"]["path"]["access"].isNull == true)
    }
}
