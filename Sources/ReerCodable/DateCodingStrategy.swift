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
    
    /// Encodes dates according to the ISO 8601 and RFC 3339 standards
    case iso8601
    
    /// Encodes a String, according to the provided static or global formatter
    case formatted(DateFormatter)
    
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
}
