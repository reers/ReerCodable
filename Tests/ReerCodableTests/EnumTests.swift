import XCTest
@testable import ReerCodable
import Testing
import Foundation

@Codable
struct User {
    let gender: Gender
    let rawInt: RawInt
    let rawDouble: RawDouble
    let rawDouble2: RawDouble2
}

@Codable
enum Gender {
    case male, female
}

@Codable
enum RawInt: Int {
    case one = 1, two, three, other = 100
}

@Codable
enum RawDouble: Double {
    case one, two, three, other = 100.0
}

@Codable
enum RawDouble2: Double {
    case one = 1.1, two = 2.2, three = 3.3, other = 4.4
}

@Codable
enum RawString: String {
    case one, two, three, other = "helloworld"
}

let enumJSONData1 = """
{
    "gender": "female",
    "rawInt": 3,
    "rawDouble": 100.0,
    "rawDouble2": 2.2
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func enum1() throws {
        // Decode
        let model = try JSONDecoder().decode(User.self, from: enumJSONData1)
        #expect(model.gender == .female)
        #expect(model.rawInt == .three)
        #expect(model.rawDouble == .other)
        #expect(model.rawDouble2 == .two)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("gender") == "female")
        #expect(dict.int("rawInt") == 3)
        #expect(dict.double("rawDouble") == 100)
        #expect(dict.double("rawDouble2") == 2.2)
    }
}
