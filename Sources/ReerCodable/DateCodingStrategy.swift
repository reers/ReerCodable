//
//  Copyright © 2015-2024 Gwendal Roué
//  Copyright © 2022 reers.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

// MARK: - Date Precision

/// Fractional seconds precision for ISO8601 date formatting
public enum DatePrecision {
    /// No fractional seconds: "10:30:00"
    case seconds
    /// Milliseconds precision (3 digits): "10:30:00.123"
    case milliseconds
    /// Microseconds precision (6 digits): "10:30:00.123456"
    case microseconds
}

// MARK: - Time Zone Style

/// Time zone representation style for ISO8601 date formatting
public enum TimeZoneStyle {
    /// UTC time zone, represented as "Z"
    case utc
    /// Local time zone of the device at runtime
    case local
    /// Fixed hour offset from UTC. Valid range: -12 to +14
    /// Example: .offsetHours(8) produces "+08:00"
    case offsetHours(Int)
    /// Fixed seconds offset from UTC. Valid range: -43200 to +50400
    /// Example: .offsetSeconds(28800) produces "+08:00"
    case offsetSeconds(Int)
    /// Time zone identifier string
    /// Example: .identifier("America/New_York") produces "-05:00" or "-04:00" depending on DST
    case identifier(String)
}

// MARK: - Date Coding Strategy

public enum DateCodingStrategy {
    /// Decodes from a Double or Encodes a Double: the number of seconds between the date and
    /// midnight UTC on 1 January 2001
    case timeIntervalSince2001
    
    /// Decodes from a Double or Encodes a Double: the number of seconds between the date and
    /// midnight UTC on 1 January 1970
    case timeIntervalSince1970
    
    /// Decodes from a Int64 or Encodes an Int64: the number of seconds between the date and
    /// midnight UTC on 1 January 1970
    case secondsSince1970
    
    /// Decodes from a Int64 or Encodes an Int64: the number of milliseconds between the date and
    /// midnight UTC on 1 January 1970
    case millisecondsSince1970
    
    /// Decodes dates from various ISO8601 formats (with or without fractional seconds, various time zones)
    /// Encodes dates to standard ISO8601 format: "2024-01-15T12:00:00Z"
    case iso8601
    
    /// Encodes a String, according to the provided static or global formatter
    case formatted(DateFormatter)
    
    /// Decodes dates from various ISO8601 formats (compatible with multiple formats)
    /// Encodes dates with configurable precision in fractional seconds and time zone
    ///
    /// - Parameters:
    ///   - precision: Fractional seconds precision (.seconds, .milliseconds, .microseconds)
    ///   - timeZone: Time zone style (.utc, .local, .offsetHours, .offsetSeconds, .identifier)
    ///
    /// Examples:
    /// - `.iso8601WithOptions()` -> "2024-01-15T12:00:00Z"
    /// - `.iso8601WithOptions(precision: .milliseconds)` -> "2024-01-15T12:00:00.123Z"
    /// - `.iso8601WithOptions(timeZone: .local)` -> "2024-01-15T20:00:00+08:00"
    /// - `.iso8601WithOptions(precision: .microseconds, timeZone: .offsetHours(-5))` -> "2024-01-15T07:00:00.123456-05:00"
    case iso8601WithOptions(precision: DatePrecision = .seconds, timeZone: TimeZoneStyle = .utc)
    
    nonisolated(unsafe) static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    nonisolated(unsafe) static let iso8601FractionalSecondsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // MARK: - High Performance ISO8601 API (iOS 15+, macOS 12+)
    
    /// Parse ISO8601 date string using modern Date.ISO8601FormatStyle (better performance)
    /// Falls back to ISO8601DateFormatter on older OS versions
    public static func parseISO8601(_ string: String) -> Date? {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            // Try standard ISO8601 format first (most common case, best performance)
            if let date = try? Date(string, strategy: .iso8601) {
                return date
            }
            // Try with fractional seconds
            if let date = try? Date(
                string,
                strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)
            ) {
                return date
            }
            return nil
        } else {
            // Fallback for older OS versions
            return iso8601Formatter.date(from: string)
                ?? iso8601FractionalSecondsFormatter.date(from: string)
        }
    }
    
    /// Format date to ISO8601 string using modern Date.ISO8601FormatStyle (better performance)
    /// Falls back to ISO8601DateFormatter on older OS versions
    public static func formatISO8601(_ date: Date) -> String {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            return date.formatted(.iso8601)
        } else {
            // Fallback for older OS versions
            return iso8601Formatter.string(from: date)
        }
    }
    
    /// Format date to ISO8601 string with configurable precision and time zone
    ///
    /// - Parameters:
    ///   - date: The date to format
    ///   - precision: Fractional seconds precision
    ///   - timeZone: Time zone style for output
    /// - Returns: Formatted ISO8601 string
    public static func formatISO8601(
        _ date: Date,
        precision: DatePrecision,
        timeZone: TimeZoneStyle
    ) -> String {
        let tz = timeZone.resolvedTimeZone
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents(in: tz, from: date)
        
        // Build date-time part
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        var result = String(format: "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day, hour, minute, second)
        
        // Add fractional seconds if needed
        switch precision {
        case .seconds:
            break
        case .milliseconds:
            let nanosecond = components.nanosecond ?? 0
            let milliseconds = nanosecond / 1_000_000
            result += String(format: ".%03d", milliseconds)
        case .microseconds:
            let nanosecond = components.nanosecond ?? 0
            let microseconds = nanosecond / 1_000
            result += String(format: ".%06d", microseconds)
        }
        
        // Add time zone
        result += timeZone.iso8601Suffix
        
        return result
    }
}

// MARK: - TimeZoneStyle Helpers

extension TimeZoneStyle {
    /// Resolve to an actual TimeZone instance
    var resolvedTimeZone: TimeZone {
        switch self {
        case .utc:
            return TimeZone(identifier: "UTC")!
        case .local:
            return TimeZone.current
        case .offsetHours(let hours):
            return TimeZone(secondsFromGMT: hours * 3600) ?? TimeZone(identifier: "UTC")!
        case .offsetSeconds(let seconds):
            return TimeZone(secondsFromGMT: seconds) ?? TimeZone(identifier: "UTC")!
        case .identifier(let id):
            return TimeZone(identifier: id) ?? TimeZone(identifier: "UTC")!
        }
    }
    
    /// Get the ISO8601 time zone suffix string
    ///
    /// Returns "Z" when offset is zero (consistent with Go, Apple, JavaScript, Java behavior),
    /// otherwise returns "+HH:MM" or "-HH:MM" format.
    var iso8601Suffix: String {
        switch self {
        case .utc:
            return "Z"
        case .local, .offsetHours, .offsetSeconds, .identifier:
            let tz = resolvedTimeZone
            let totalSeconds = tz.secondsFromGMT()
            if totalSeconds == 0 {
                return "Z"
            }
            let sign = totalSeconds >= 0 ? "+" : "-"
            let absSeconds = abs(totalSeconds)
            let hours = absSeconds / 3600
            let minutes = (absSeconds % 3600) / 60
            return String(format: "%@%02d:%02d", sign, hours, minutes)
        }
    }
}
