@testable import ReerCodable
import Testing
import Foundation

@Codable
@SnakeCase
struct Person2 {
    var firstName: String
    
    @CodingKey("avatar_url")
    var avatarURL: URL
}

let jsonData5 = """
{
    "first_name": "Phoenix",
    "avatar_url": "http://abc.com/image.png"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func namingConvention() throws {
        // Decode
        let model = try JSONDecoder().decode(Person2.self, from: jsonData5)
        #expect(model.firstName == "Phoenix")
        #expect(model.avatarURL.absoluteString == "http://abc.com/image.png")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("first_name") == "Phoenix")
        #expect(dict.string("avatar_url") == "http://abc.com/image.png")
    }
}


@Codable
@FlatCase
@UpperCase
@CamelCase
@PascalCase
@SnakeCase
@KebabCase
@CamelSnakeCase
@PascalSnakeCase
@ScreamingSnakeCase
@CamelKebabCase
@PascalKebabCase
@ScreamingKebabCase
struct Model {
    @EncodingKey("two#words")
    var twoWords: String
}

extension TestReerCodable {
    @Test(
        arguments: [
            "twowords", "TWOWORDS", "twoWords", "TwoWords", "two_words", "two-words",
            "two_Words", "Two_Words", "TWO_WORDS", "two-Words", "Two-Words", "TWO-WORDS"
        ]
    )
    func allCases(caseString: String) throws {
        let caseJsonData = "{\"\(caseString)\": \"Hit\"}".data(using: .utf8)!
        // Decode
        let model = try JSONDecoder().decode(Model.self, from: caseJsonData)
        #expect(model.twoWords == "Hit")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("two#words") == "Hit")
    }
}

@Codable
struct Model2 {
    @FlatCase
    @UpperCase
    @CamelCase
    @PascalCase
    @SnakeCase
    @KebabCase
    @CamelSnakeCase
    @PascalSnakeCase
    @ScreamingSnakeCase
    @CamelKebabCase
    @PascalKebabCase
    @ScreamingKebabCase
    @EncodingKey("two#words")
    var twoWords: String
}

extension TestReerCodable {
    @Test(
        arguments: [
            "twowords", "TWOWORDS", "twoWords", "TwoWords", "two_words", "two-words",
            "two_Words", "Two_Words", "TWO_WORDS", "two-Words", "Two-Words", "TWO-WORDS"
        ]
    )
    func allCases2(caseString: String) throws {
        let caseJsonData = "{\"\(caseString)\": \"Hit\"}".data(using: .utf8)!
        // Decode
        let model = try JSONDecoder().decode(Model2.self, from: caseJsonData)
        #expect(model.twoWords == "Hit")
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.string("two#words") == "Hit")
    }
}
