@testable import ReerCodable
import Foundation
import Testing

@Codable
nonisolated struct NonisolatedCodableStruct: Equatable {
    let id: Int
    let name: String
}

@Codable
nonisolated final class NonisolatedCodableClass {
    let id: Int
    let name: String
}

@Codable
nonisolated enum NonisolatedCodableEnum: String {
    case active
    case paused
}

@Decodable
nonisolated struct NonisolatedDecodableStruct: Equatable {
    let id: Int
}

@Encodable
nonisolated struct NonisolatedEncodableStruct {
    let id: Int
}

private func roundTrip<T: Codable>(_ value: T, as type: T.Type = T.self) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}

extension TestReerCodable {
    @Test
    func nonisolatedCodableStructRoundTrips() throws {
        let original = NonisolatedCodableStruct(id: 1, name: "Phoenix")
        let decoded = try roundTrip(original)

        #expect(decoded == original)
    }

    @Test
    func nonisolatedCodableClassRoundTrips() throws {
        let original = NonisolatedCodableClass(id: 2, name: "Reer")
        let decoded = try roundTrip(original)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
    }

    @Test
    func nonisolatedCodableEnumRoundTrips() throws {
        let decoded = try roundTrip(NonisolatedCodableEnum.active)

        #expect(decoded == .active)
    }

    @Test
    func nonisolatedDecodableStructDecodes() throws {
        let data = #"{"id":3}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(NonisolatedDecodableStruct.self, from: data)

        #expect(decoded.id == 3)
    }

    @Test
    func nonisolatedEncodableStructEncodes() throws {
        let data = try JSONEncoder().encode(NonisolatedEncodableStruct(id: 4))
        let dict = data.stringAnyDictionary

        #expect(dict.int("id") == 4)
    }
}
