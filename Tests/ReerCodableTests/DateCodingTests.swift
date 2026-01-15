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

// MARK: - ISO8601 Fractional Seconds Tests

@Codable
struct ISO8601FractionalModel {
    @DateCoding(.iso8601)
    var standardDate: Date
    
    @DateCoding(.iso8601)
    var fractionalDate: Date
    
    @DateCoding(.iso8601)
    var highPrecisionDate: Date
    
    @DateCoding(.iso8601)
    var timezoneOffsetDate: Date
    
    @DateCoding(.iso8601)
    var fractionalWithTimezoneDate: Date
}

extension TestReerCodable {
    
    /// Test ISO8601 parsing with various fractional seconds formats
    @Test
    func iso8601FractionalSeconds() throws {
        let jsonData = """
        {
            "standardDate": "2024-06-15T10:30:00Z",
            "fractionalDate": "2024-06-15T10:30:00.123Z",
            "highPrecisionDate": "2024-06-15T10:30:00.123456Z",
            "timezoneOffsetDate": "2024-06-15T18:30:00+08:00",
            "fractionalWithTimezoneDate": "2024-06-15T18:30:00.500+08:00"
        }
        """.data(using: .utf8)!
        
        // Decode
        let model = try JSONDecoder().decode(ISO8601FractionalModel.self, from: jsonData)
        
        // 2024-06-15T10:30:00Z = 1718447400.0
        #expect(model.standardDate.timeIntervalSince1970 == 1718447400.0)
        
        // 2024-06-15T10:30:00.123Z = 1718447400.123
        #expect(abs(model.fractionalDate.timeIntervalSince1970 - 1718447400.123) < 0.001)
        
        // 2024-06-15T10:30:00.123456Z - verify microseconds precision with modern API
        #expect(abs(model.highPrecisionDate.timeIntervalSince1970 - 1718447400.123456) < 0.000001)
        
        // 2024-06-15T18:30:00+08:00 = 2024-06-15T10:30:00Z = 1718447400.0
        #expect(model.timezoneOffsetDate.timeIntervalSince1970 == 1718447400.0)
        
        // 2024-06-15T18:30:00.500+08:00 = 2024-06-15T10:30:00.500Z = 1718447400.5
        #expect(abs(model.fractionalWithTimezoneDate.timeIntervalSince1970 - 1718447400.5) < 0.001)
        
        // Encode - verify output format is standard ISO8601 (without fractional seconds)
        let encodedData = try JSONEncoder().encode(model)
        let dict = encodedData.stringAnyDictionary
        
        #expect(dict.string("standardDate") == "2024-06-15T10:30:00Z")
        // Encoded dates should be in standard format (fractional seconds are not preserved in output)
        #expect(dict.string("fractionalDate") == "2024-06-15T10:30:00Z")
        #expect(dict.string("timezoneOffsetDate") == "2024-06-15T10:30:00Z")
    }
    
    /// Test DateCodingStrategy.parseISO8601 directly
    @Test
    func parseISO8601Directly() throws {
        // Standard format
        let date1 = DateCodingStrategy.parseISO8601("2024-01-15T12:00:00Z")
        #expect(date1 != nil)
        #expect(date1?.timeIntervalSince1970 == 1705320000.0)
        
        // With milliseconds
        let date2 = DateCodingStrategy.parseISO8601("2024-01-15T12:00:00.123Z")
        #expect(date2 != nil)
        #expect(abs(date2!.timeIntervalSince1970 - 1705320000.123) < 0.001)
        
        // With microseconds - verify high precision support
        let date3 = DateCodingStrategy.parseISO8601("2024-01-15T12:00:00.123456Z")
        #expect(date3 != nil)
        #expect(abs(date3!.timeIntervalSince1970 - 1705320000.123456) < 0.000001)
        
        // With positive timezone offset
        let date4 = DateCodingStrategy.parseISO8601("2024-01-15T20:00:00+08:00")
        #expect(date4 != nil)
        #expect(date4?.timeIntervalSince1970 == 1705320000.0) // Same as 12:00:00Z
        
        // With negative timezone offset
        let date5 = DateCodingStrategy.parseISO8601("2024-01-15T07:00:00-05:00")
        #expect(date5 != nil)
        #expect(date5?.timeIntervalSince1970 == 1705320000.0) // Same as 12:00:00Z
        
        // Fractional with timezone offset (edge case: new API has bug, fallback to ISO8601DateFormatter)
        let date6 = DateCodingStrategy.parseISO8601("2024-01-15T20:00:00.999+08:00")
        #expect(date6 != nil)
        #expect(abs(date6!.timeIntervalSince1970 - 1705320000.999) < 0.001)
        
        // Invalid format should return nil
        let invalidDate = DateCodingStrategy.parseISO8601("not-a-date")
        #expect(invalidDate == nil)
        
        let invalidDate2 = DateCodingStrategy.parseISO8601("2024/01/15")
        #expect(invalidDate2 == nil)
    }
    
    /// Test DateCodingStrategy.formatISO8601 directly
    @Test
    func formatISO8601Directly() throws {
        let date = Date(timeIntervalSince1970: 1705320000.0) // 2024-01-15T12:00:00Z
        let formatted = DateCodingStrategy.formatISO8601(date)
        #expect(formatted == "2024-01-15T12:00:00Z")
        
        // Date with fractional seconds - output should still be standard format
        let dateWithFraction = Date(timeIntervalSince1970: 1705320000.123)
        let formattedFraction = DateCodingStrategy.formatISO8601(dateWithFraction)
        // Note: formatISO8601 outputs standard format without fractional seconds
        #expect(formattedFraction == "2024-01-15T12:00:00Z")
    }
}
