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

// MARK: - ISO8601 With Options Tests

@Codable
struct ISO8601WithOptionsModel {
    // Default: seconds precision, UTC timezone
    @DateCoding(.iso8601WithOptions())
    var defaultDate: Date
    
    // Milliseconds precision, UTC timezone
    @DateCoding(.iso8601WithOptions(precision: .milliseconds))
    var millisecondsDate: Date
    
    // Microseconds precision, UTC timezone
    @DateCoding(.iso8601WithOptions(precision: .microseconds))
    var microsecondsDate: Date
    
    // Seconds precision, local timezone
    @DateCoding(.iso8601WithOptions(timeZone: .local))
    var localDate: Date
    
    // Milliseconds precision, fixed +08:00 timezone
    @DateCoding(.iso8601WithOptions(precision: .milliseconds, timeZone: .offsetHours(8)))
    var beijingDate: Date
    
    // Microseconds precision, fixed -05:00 timezone
    @DateCoding(.iso8601WithOptions(precision: .microseconds, timeZone: .offsetHours(-5)))
    var newYorkDate: Date
    
    // Seconds precision, identifier timezone
    @DateCoding(.iso8601WithOptions(timeZone: .identifier("Asia/Tokyo")))
    var tokyoDate: Date
    
    // Milliseconds precision, offset seconds (3600 = +01:00)
    @DateCoding(.iso8601WithOptions(precision: .milliseconds, timeZone: .offsetSeconds(3600)))
    var parisDate: Date
}

extension TestReerCodable {
    
    /// Test iso8601WithOptions encoding with various precision and timezone combinations
    @Test
    func iso8601WithOptionsEncoding() throws {
        // Create a date: 2024-01-15T12:00:00.123456Z
        let date = Date(timeIntervalSince1970: 1705320000.123456)
        
        // Test formatISO8601 with options directly
        
        // Default: seconds, UTC -> "2024-01-15T12:00:00Z"
        let defaultFormatted = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .utc)
        #expect(defaultFormatted == "2024-01-15T12:00:00Z")
        
        // Milliseconds, UTC -> "2024-01-15T12:00:00.123Z"
        let msFormatted = DateCodingStrategy.formatISO8601(date, precision: .milliseconds, timeZone: .utc)
        #expect(msFormatted == "2024-01-15T12:00:00.123Z")
        
        // Microseconds, UTC -> "2024-01-15T12:00:00.123456Z"
        let usFormatted = DateCodingStrategy.formatISO8601(date, precision: .microseconds, timeZone: .utc)
        #expect(usFormatted == "2024-01-15T12:00:00.123456Z")
        
        // Seconds, +08:00 -> "2024-01-15T20:00:00+08:00"
        let beijing = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetHours(8))
        #expect(beijing == "2024-01-15T20:00:00+08:00")
        
        // Milliseconds, +08:00 -> "2024-01-15T20:00:00.123+08:00"
        let beijingMs = DateCodingStrategy.formatISO8601(date, precision: .milliseconds, timeZone: .offsetHours(8))
        #expect(beijingMs == "2024-01-15T20:00:00.123+08:00")
        
        // Microseconds, -05:00 -> "2024-01-15T07:00:00.123456-05:00"
        let nyUs = DateCodingStrategy.formatISO8601(date, precision: .microseconds, timeZone: .offsetHours(-5))
        #expect(nyUs == "2024-01-15T07:00:00.123456-05:00")
        
        // Seconds, +09:00 (Tokyo) -> "2024-01-15T21:00:00+09:00"
        let tokyo = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .identifier("Asia/Tokyo"))
        #expect(tokyo == "2024-01-15T21:00:00+09:00")
        
        // Milliseconds, +01:00 (offsetSeconds) -> "2024-01-15T13:00:00.123+01:00"
        let paris = DateCodingStrategy.formatISO8601(date, precision: .milliseconds, timeZone: .offsetSeconds(3600))
        #expect(paris == "2024-01-15T13:00:00.123+01:00")
    }
    
    /// Test iso8601WithOptions decoding (should be compatible with various formats)
    @Test
    func iso8601WithOptionsDecoding() throws {
        let jsonData = """
        {
            "defaultDate": "2024-01-15T12:00:00Z",
            "millisecondsDate": "2024-01-15T12:00:00.123Z",
            "microsecondsDate": "2024-01-15T12:00:00.123456Z",
            "localDate": "2024-01-15T20:00:00+08:00",
            "beijingDate": "2024-01-15T20:00:00.123+08:00",
            "newYorkDate": "2024-01-15T07:00:00.123456-05:00",
            "tokyoDate": "2024-01-15T21:00:00+09:00",
            "parisDate": "2024-01-15T13:00:00.123+01:00"
        }
        """.data(using: .utf8)!
        
        // Decode
        let model = try JSONDecoder().decode(ISO8601WithOptionsModel.self, from: jsonData)
        
        // All dates should decode to the same timestamp: 1705320000.0 (with varying fractional parts)
        let baseTimestamp = 1705320000.0
        
        #expect(model.defaultDate.timeIntervalSince1970 == baseTimestamp)
        #expect(abs(model.millisecondsDate.timeIntervalSince1970 - (baseTimestamp + 0.123)) < 0.001)
        #expect(abs(model.microsecondsDate.timeIntervalSince1970 - (baseTimestamp + 0.123456)) < 0.000001)
        #expect(model.localDate.timeIntervalSince1970 == baseTimestamp)
        #expect(abs(model.beijingDate.timeIntervalSince1970 - (baseTimestamp + 0.123)) < 0.001)
        #expect(abs(model.newYorkDate.timeIntervalSince1970 - (baseTimestamp + 0.123456)) < 0.000001)
        #expect(model.tokyoDate.timeIntervalSince1970 == baseTimestamp)
        #expect(abs(model.parisDate.timeIntervalSince1970 - (baseTimestamp + 0.123)) < 0.001)
    }
    
    /// Test iso8601WithOptions full encode/decode cycle
    @Test
    func iso8601WithOptionsRoundTrip() throws {
        let jsonData = """
        {
            "defaultDate": "2024-01-15T12:00:00Z",
            "millisecondsDate": "2024-01-15T12:00:00.123Z",
            "microsecondsDate": "2024-01-15T12:00:00.123456Z",
            "localDate": "2024-01-15T12:00:00Z",
            "beijingDate": "2024-01-15T12:00:00.123Z",
            "newYorkDate": "2024-01-15T12:00:00.123456Z",
            "tokyoDate": "2024-01-15T12:00:00Z",
            "parisDate": "2024-01-15T12:00:00.123Z"
        }
        """.data(using: .utf8)!
        
        // Decode
        let model = try JSONDecoder().decode(ISO8601WithOptionsModel.self, from: jsonData)
        
        // Encode
        let encodedData = try JSONEncoder().encode(model)
        let dict = encodedData.stringAnyDictionary
        
        // Verify encoding formats
        #expect(dict.string("defaultDate") == "2024-01-15T12:00:00Z")
        #expect(dict.string("millisecondsDate") == "2024-01-15T12:00:00.123Z")
        #expect(dict.string("microsecondsDate") == "2024-01-15T12:00:00.123456Z")
        // localDate uses device's local timezone, so we can't assert exact value
        
        // Beijing time (+08:00): 12:00 UTC = 20:00 Beijing
        #expect(dict.string("beijingDate") == "2024-01-15T20:00:00.123+08:00")
        
        // New York time (-05:00): 12:00 UTC = 07:00 New York
        #expect(dict.string("newYorkDate") == "2024-01-15T07:00:00.123456-05:00")
        
        // Tokyo time (+09:00): 12:00 UTC = 21:00 Tokyo
        #expect(dict.string("tokyoDate") == "2024-01-15T21:00:00+09:00")
        
        // Paris time (+01:00): 12:00 UTC = 13:00 Paris
        #expect(dict.string("parisDate") == "2024-01-15T13:00:00.123+01:00")
    }
    
    /// Test TimeZoneStyle helper methods
    @Test
    func timeZoneStyleHelpers() throws {
        // UTC
        let utcTz = TimeZoneStyle.utc.resolvedTimeZone
        #expect(utcTz.secondsFromGMT() == 0)
        #expect(TimeZoneStyle.utc.iso8601Suffix == "Z")
        
        // Offset hours positive
        let plus8 = TimeZoneStyle.offsetHours(8)
        #expect(plus8.resolvedTimeZone.secondsFromGMT() == 8 * 3600)
        #expect(plus8.iso8601Suffix == "+08:00")
        
        // Offset hours negative
        let minus5 = TimeZoneStyle.offsetHours(-5)
        #expect(minus5.resolvedTimeZone.secondsFromGMT() == -5 * 3600)
        #expect(minus5.iso8601Suffix == "-05:00")
        
        // Offset seconds
        let offsetSec = TimeZoneStyle.offsetSeconds(5400) // 1.5 hours
        #expect(offsetSec.resolvedTimeZone.secondsFromGMT() == 5400)
        #expect(offsetSec.iso8601Suffix == "+01:30")
        
        // Identifier
        let tokyo = TimeZoneStyle.identifier("Asia/Tokyo")
        #expect(tokyo.resolvedTimeZone.identifier == "Asia/Tokyo")
        // Tokyo is +09:00
        #expect(tokyo.iso8601Suffix == "+09:00")
    }
    
    /// Test edge cases for timezone offsets
    @Test
    func timeZoneEdgeCases() throws {
        let date = Date(timeIntervalSince1970: 1705320000.0) // 2024-01-15T12:00:00Z
        
        // Maximum positive offset: UTC+14 (Line Islands, Kiribati)
        let plus14 = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetHours(14))
        #expect(plus14 == "2024-01-16T02:00:00+14:00")
        
        // Maximum negative offset: UTC-12 (Baker Island)
        let minus12 = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetHours(-12))
        #expect(minus12 == "2024-01-15T00:00:00-12:00")
        
        // Non-whole-hour offset: UTC+05:30 (India)
        let india = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetSeconds(5 * 3600 + 30 * 60))
        #expect(india == "2024-01-15T17:30:00+05:30")
        
        // UTC+12:45 (Chatham Islands)
        let chatham = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetSeconds(12 * 3600 + 45 * 60))
        #expect(chatham == "2024-01-16T00:45:00+12:45")
    }
    
    /// Test zero offset timezone behavior
    /// All zero offset cases output "Z" (consistent with Go, Apple, JavaScript, Java)
    @Test
    func zeroOffsetTimezoneBehavior() throws {
        let date = Date(timeIntervalSince1970: 1705320000.0) // 2024-01-15T12:00:00Z
        
        // .utc -> "Z"
        let utcFormatted = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .utc)
        #expect(utcFormatted == "2024-01-15T12:00:00Z")
        #expect(TimeZoneStyle.utc.iso8601Suffix == "Z")
        
        // .offsetHours(0) -> "Z"
        let offsetHours0 = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetHours(0))
        #expect(offsetHours0 == "2024-01-15T12:00:00Z")
        #expect(TimeZoneStyle.offsetHours(0).iso8601Suffix == "Z")
        
        // .offsetSeconds(0) -> "Z"
        let offsetSeconds0 = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .offsetSeconds(0))
        #expect(offsetSeconds0 == "2024-01-15T12:00:00Z")
        #expect(TimeZoneStyle.offsetSeconds(0).iso8601Suffix == "Z")
        
        // .identifier("UTC") -> "Z"
        let identifierUTC = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .identifier("UTC"))
        #expect(identifierUTC == "2024-01-15T12:00:00Z")
        #expect(TimeZoneStyle.identifier("UTC").iso8601Suffix == "Z")
        
        // .identifier("GMT") -> "Z"
        let identifierGMT = DateCodingStrategy.formatISO8601(date, precision: .seconds, timeZone: .identifier("GMT"))
        #expect(identifierGMT == "2024-01-15T12:00:00Z")
        #expect(TimeZoneStyle.identifier("GMT").iso8601Suffix == "Z")
        
        // Verify with milliseconds precision
        let dateWithMs = Date(timeIntervalSince1970: 1705320000.0 + 0.5) // .500 is exact in binary
        
        // .utc with milliseconds -> "Z"
        let msUTC = DateCodingStrategy.formatISO8601(dateWithMs, precision: .milliseconds, timeZone: .utc)
        #expect(msUTC == "2024-01-15T12:00:00.500Z")
        
        // .offsetHours(0) with milliseconds -> "Z"
        let msOffset0 = DateCodingStrategy.formatISO8601(dateWithMs, precision: .milliseconds, timeZone: .offsetHours(0))
        #expect(msOffset0 == "2024-01-15T12:00:00.500Z")
        
        // .offsetSeconds(0) with milliseconds -> "Z"
        let msOffsetSec0 = DateCodingStrategy.formatISO8601(dateWithMs, precision: .milliseconds, timeZone: .offsetSeconds(0))
        #expect(msOffsetSec0 == "2024-01-15T12:00:00.500Z")
    }
}
