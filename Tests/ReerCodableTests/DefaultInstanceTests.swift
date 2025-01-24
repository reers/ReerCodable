import XCTest
@testable import ReerCodable
import Testing
import Foundation

@Codable
@DefaultInstance
struct VideoInfo: Equatable {
    var title: String
}

@Codable
@DefaultInstance
enum Video3: Equatable {
    case tiktok(url: URL, id: Int = 56, desc: String, VideoInfo)
    case youtube
    
    static func == (lhs: Video3, rhs: Video3) -> Bool {
        switch (lhs, rhs) {
        case (.youtube, .youtube):
            return true
        case let (
            .tiktok(lUrl, lId, lDesc, lInfo),
            .tiktok(rUrl, rId, rDesc, rInfo)
        ):
            return lUrl == rUrl
                && lId == rId
                && lDesc == rDesc
                && lInfo == rInfo
        default:
            return false
        }
    }
}

@Codable
@DefaultInstance
enum Video4 {
    case douyin
    case bilibili
}

@Codable
enum Phone2 {
    case iOS
    case android
    
    // impl a default by user
    static let `default` = Self.android
}

@Codable
@DefaultInstance
struct ImageModel {
    var url: URL
}

@Codable
@DefaultInstance
struct User5 {
    let name: String
    var age: Int = 22
    var uInt: UInt = 3
    var data: Data
    var date: Date
    var decimal: Decimal = 8
    var uuid: UUID
    var avatar: ImageModel
    var video3: Video3
    var video4: Video4
    var phone: Phone2
    var optional: String? = "123"
    var optional2: String?
}


extension TestReerCodable {
    @Test
    func defaultInstance() throws {
        #expect(User5.default.name == "")
        #expect(User5.default.age == 22)
        #expect(User5.default.uInt == 3)
        #expect(User5.default.data == Data())
        #expect(User5.default.decimal == Decimal(8))
        #expect(User5.default.avatar.url == URL(string: "/")!)
        #expect(User5.default.video3 == Video3.tiktok(url: URL(string: "/")!, id: 56, desc: "", VideoInfo.default))
        #expect(User5.default.video4 == Video4.douyin)
        #expect(User5.default.phone == Phone2.android)
        #expect(User5.default.optional == "123")
        #expect(User5.default.optional2 == nil)
    }
}
