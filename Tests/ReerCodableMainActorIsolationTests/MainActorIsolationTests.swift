import Foundation
import ReerCodable
import Testing

@Codable
nonisolated struct MainActorDefaultCodableModel: Sendable {
    let id: Int
    let name: String
}

@Decodable
nonisolated struct MainActorDefaultDecodableModel: Sendable {
    let id: Int
}

@Encodable
nonisolated struct MainActorDefaultEncodableModel: Sendable {
    let id: Int
}

private func acceptsCodableSendable<T: Codable & Sendable>(_ type: T.Type) {}

private func acceptsDecodableSendable<T: Decodable & Sendable>(_ type: T.Type) {}

private func acceptsEncodableSendable<T: Encodable & Sendable>(_ type: T.Type) {}

@Test
func nonisolatedCodableConformanceSatisfiesNonisolatedGenericRequirement() throws {
    acceptsCodableSendable(MainActorDefaultCodableModel.self)

    let original = MainActorDefaultCodableModel(id: 1, name: "Reer")
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(MainActorDefaultCodableModel.self, from: data)

    #expect(decoded.id == original.id)
    #expect(decoded.name == original.name)
}

@Test
func nonisolatedDecodableConformanceSatisfiesNonisolatedGenericRequirement() throws {
    acceptsDecodableSendable(MainActorDefaultDecodableModel.self)

    let data = #"{"id":2}"#.data(using: .utf8)!
    let decoded = try JSONDecoder().decode(MainActorDefaultDecodableModel.self, from: data)

    #expect(decoded.id == 2)
}

@Test
func nonisolatedEncodableConformanceSatisfiesNonisolatedGenericRequirement() throws {
    acceptsEncodableSendable(MainActorDefaultEncodableModel.self)

    let data = try JSONEncoder().encode(MainActorDefaultEncodableModel(id: 3))
    let value = try #require(data.stringAnyDictionary?["id"] as? Int)

    #expect(value == 3)
}

private extension Data {
    var stringAnyDictionary: [String: Any]? {
        try? JSONSerialization.jsonObject(with: self) as? [String: Any]
    }
}
