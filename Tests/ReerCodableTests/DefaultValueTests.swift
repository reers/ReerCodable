@testable import ReerCodable
import Foundation
import Testing

@Decodable
private struct DecodingDefaultsModel: Equatable {
    @DecodingDefault(false)
    var isEnabled: Bool
    
    @CodingKey("retries")
    @DecodingDefault(3)
    var retryCount: Int
}

@Encodable
private struct EncodingDefaultsModel {
    @EncodingDefault("anonymous")
    var nickname: String?
    
    @EncodingDefault(Data([0x48, 0x69]))
    @Base64Coding
    var payload: Data?
}

@Codable
private struct CodingDefaultsModel: Equatable {
    @CodingDefault(["seed": 1])
    var metadata: [String: Int]?
    
    @CodingDefault(false)
    var isEnabled: Bool
}

struct DefaultValueTests {
    @Test
    func decodingDefaults() throws {
        let emptyData = "{}".data(using: .utf8)!
        let decodedEmpty = try JSONDecoder().decode(DecodingDefaultsModel.self, from: emptyData)
        #expect(decodedEmpty.isEnabled == false)
        #expect(decodedEmpty.retryCount == 3)
        
        let mismatched = #"{"retries":"oops"}"#.data(using: .utf8)!
        let decodedMismatch = try JSONDecoder().decode(DecodingDefaultsModel.self, from: mismatched)
        #expect(decodedMismatch.retryCount == 3)
        
        let filled = #"{"isEnabled":true,"retries":5}"#.data(using: .utf8)!
        let decodedFilled = try JSONDecoder().decode(DecodingDefaultsModel.self, from: filled)
        #expect(decodedFilled.isEnabled == true)
        #expect(decodedFilled.retryCount == 5)
    }
    
    @Test
    func encodingDefaults() throws {
        var model = EncodingDefaultsModel(nickname: nil, payload: nil)
        var dict = try model.encodedDict()
        #expect(dict.string("nickname") == "anonymous")
        #expect(dict.string("payload") == "SGk=") // "Hi"
        
        model.nickname = "phoenix"
        model.payload = Data([0x21])
        dict = try model.encodedDict()
        #expect(dict.string("nickname") == "phoenix")
        #expect(dict.string("payload") == "IQ==")
    }
    
    @Test
    func codingDefaults() throws {
        let decoded = try JSONDecoder().decode(CodingDefaultsModel.self, from: "{}".data(using: .utf8)!)
        #expect(decoded.metadata == ["seed": 1])
        #expect(decoded.isEnabled == false)
        
        var mutable = decoded
        mutable.metadata = nil
        let encoded = try mutable.encodedDict()
        #expect((encoded["metadata"] as? [String: Int]) == ["seed": 1])
        
        mutable.metadata = ["seed": 9]
        let updated = try mutable.encodedDict()
        #expect((updated["metadata"] as? [String: Int]) == ["seed": 9])
    }
}
