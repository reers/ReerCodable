import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ReerCodable
import Testing
import Foundation

// 1st 2nd 3rd 4th 5th  -> 1 2 3 4 5
struct RankTransformer: CodingCustomizable {
    typealias Value = UInt
    
    static func decode(by decoder: any Decoder) throws -> UInt {
        var temp: String = try decoder.value(forKeys: "rank")
        temp.removeLast(2)
        return UInt(temp) ?? 0
    }
    
    static func encode(by encoder: any Encoder, _ value: UInt) throws {
        try encoder.set(value, forKey: "rank")
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
    var rank: UInt
}

let jsonData2 = """
{
    "milliseconds": 11200,
    "rank": "2nd"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func custom() throws {
        // Decode
        let model = try JSONDecoder().decode(HundredMeterRace.self, from: jsonData2)
        #expect(model.duration == 11.2)
        #expect(model.rank == 2)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.double("seconds") == 11.2)
        #expect(dict.int("rank") == 2)
    }
}
