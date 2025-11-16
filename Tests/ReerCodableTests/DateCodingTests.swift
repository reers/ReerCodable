import XCTest
@testable import ReerCodable
import Testing
import Foundation



@Codable
class DateModel {
    @DateCoding(.timeIntervalSince2001)
    var date1: Date
    
    @DateCoding(.timeIntervalSince1970)
    var date2: Date
    
    @DateCoding(.secondsSince1970)
    var date3: Date
    
    @DateCoding(.millisecondsSince1970)
    var date4: Date
    
    @DateCoding(.iso8601)
    var date5: Date
    
    @DateCoding(.iso8601)
    var date6: Date
    
    @DateCoding(.formatted(Self.formatter))
    var date7: Date
    
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'Year'MM'-Month'dd'*Day 'HH'h'mm'm'ss's'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}

let jsonData4 = """
{
    "date1": 1431585275,
    "date2": 1731585275.944,
    "date3": 1731585275,
    "date4": 1731585275944,
    "date5": "2024-12-10T00:00:00Z",
    "date6": "2025-04-17T00:00:00.000Z",
    "date7": "2024Year12-Month10*Day 00h00m00s"
}
""".data(using: .utf8)!

extension TestReerCodable {
    @Test
    func date() throws {
        // Decode
        let model = try JSONDecoder().decode(DateModel.self, from: jsonData4)
        #expect(model.date1.timeIntervalSinceReferenceDate == 1431585275)
        #expect(model.date2.timeIntervalSince1970 == 1731585275.944)
        #expect(model.date3.timeIntervalSince1970 == 1731585275)
        #expect(model.date4.timeIntervalSince1970 * 1000 == 1731585275944)
        #expect(model.date5.timeIntervalSince1970 == 1733788800.0)
        #expect(model.date6.timeIntervalSince1970 == 1744848000.0)
        #expect(model.date7.timeIntervalSince1970 == 1733788800.0)
        
        // Encode
        let modelData = try JSONEncoder().encode(model)
        let dict = modelData.stringAnyDictionary
        if let dict {
            print(dict)
        }
        #expect(dict.double("date1") == 1431585275)
        #expect(dict.double("date2") == 1731585275.944)
        #expect(dict.int("date3") == 1731585275)
        #expect(dict.double("date4") == 1731585275944)
        #expect(dict.string("date5") == "2024-12-10T00:00:00Z")
        #expect(dict.string("date6") == "2025-04-17T00:00:00Z")
        #expect(dict.string("date7") == "2024Year12-Month10*Day 00h00m00s")
    }
}
