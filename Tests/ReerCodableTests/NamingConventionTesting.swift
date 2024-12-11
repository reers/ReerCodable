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
