@testable import ReerCodable
import Testing
import Foundation

// 1st 2nd 3rd 4th 5th  -> 1 2 3 4 5
struct RankTransformer: CodingCustomizable {
    
    typealias Value = UInt
    
    static func decode(by decoder: any Decoder, keys: [String]) throws -> Value {
        var temp: String = try decoder.value(forKeys: keys)
        temp.removeLast(2)
        return UInt(temp) ?? 0
    }
    
    static func encode(by encoder: Encoder, key: String, value: Value) throws {
        try encoder.set(value, forKey: key)
    }
}


struct AddPrefixTransformer<T: Codable>: CodingCustomizable {
    static func decode(by decoder: any Decoder, keys: [String]) throws -> T {
        var temp: String = try decoder.value(forKeys: keys)
        return "prefix-\(temp)" as! T
    }
    
    static func encode(by encoder: Encoder, key: String, value: T) throws {
        try encoder.set(value, forKey: key)
    }
}


@Codable
struct HundredMeterRace {
    
    @CustomCoding<Double>(
        decode: { decoder in
            let temp: Double = try decoder.value(forKeys: "milliseconds")
            return temp / 1000
        },
        encode: { encoder, value in
            try encoder.set(value, forKey: "seconds")
        }
    )
    var duration: TimeInterval
    
    @CustomCoding(RankTransformer.self)
    @CodingKey("race_rank")
    var rank: UInt
    
    @CustomCoding(RankTransformer.self)
    @KebabCase
    @EncodingKey("TEST~~Case")
    var testCase: UInt
    
    @CustomCoding(AddPrefixTransformer<String>.self)
    var testGeneric: String
}

let jsonData2 = """
{
    "milliseconds": 11200,
    "race_rank": "2nd",
    "test-case": "3rd",
    "testGeneric": "helloworld"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func custom() throws {
        // Decode
        let model = try JSONDecoder().decode(HundredMeterRace.self, from: jsonData2)
        #expect(model.duration == 11.2)
        #expect(model.rank == 2)
        #expect(model.testCase == 3)
        #expect(model.testGeneric == "prefix-helloworld")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.double("seconds") == 11.2)
        #expect(dict.int("race_rank") == 2)
        #expect(dict.int("TEST~~Case") == 3)
        #expect(dict.string("testGeneric") == "prefix-helloworld")
    }
}
