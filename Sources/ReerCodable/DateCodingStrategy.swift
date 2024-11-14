//
//  DateCodingStrategy.swift
//  ReerCodable
//
//  Created by phoenix on 2024/11/14.
//

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
    
    /// Encodes a String, according to the provided formatter
    case formatted(DateFormatter)
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
//    public func decode(from: String) throws -> Date {
//        
//    }
    
//    public func encode(_ date: Date) -> String {
//        switch self {
//        case .timeIntervalSince2001:
//            return date.timeIntervalSinceReferenceDate
//        default:
//            <#code#>
//        }
//        switch self {
//        case .deferredToDate:
//            return date.databaseValue
//        case .timeIntervalSinceReferenceDate:
//            return date.timeIntervalSinceReferenceDate.databaseValue
//        case .timeIntervalSince1970:
//            return date.timeIntervalSince1970.databaseValue
//        case .millisecondsSince1970:
//            return Int64(floor(1000.0 * date.timeIntervalSince1970)).databaseValue
//        case .secondsSince1970:
//            return Int64(floor(date.timeIntervalSince1970)).databaseValue
//        case .iso8601:
//            return Self.iso8601Formatter.string(from: date).databaseValue
//        case .formatted(let formatter):
//            return formatter.string(from: date).databaseValue
//        case .custom(let format):
//            return format(date)?.databaseValue ?? .null
//        }
//    }
}
