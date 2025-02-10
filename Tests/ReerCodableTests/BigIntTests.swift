@testable import ReerCodable
import Testing
import Foundation


@Codable
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
struct TestBigInt {
    var int128: Int128
    var uint128: UInt128
}

let jsonbigint = [
    "int128": "170141183460469231731687303715884105727",
    "uint128": "340282366920938463463374607431768211455"
]

extension TestReerCodable {
    @Test
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func bigint() throws {
        let model = try TestBigInt.decoded(from: jsonbigint)
        #expect(model.int128 == 170141183460469231731687303715884105727)
        #expect(model.uint128 == 340282366920938463463374607431768211455)
        
        let dict = try model.encodedDict()
        #expect(dict.string("int128") == "170141183460469231731687303715884105727")
        #expect(dict.string("uint128") == "340282366920938463463374607431768211455")
    }
}
