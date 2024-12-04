//
//  Copyright © 2024 reers.
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

/// The `@DateCoding` macro provides flexible date encoding and decoding strategies.
///
/// This macro supports various date formatting strategies:
/// - Timestamp-based strategies (seconds or milliseconds since epoch)
/// - ISO8601 standard format
/// - Custom date formatter
///
/// Example usage:
/// ```swift
/// @Codable
/// struct Event {
///     @DateCoding(.millisecondsSince1970)
///     var timestamp: Date?  // Encoded as milliseconds timestamp
///     
///     @DateCoding(.iso8601)
///     var createdAt: Date  // Encoded as ISO8601 string
///     
///     @DateCoding(.formatted(formatter))  // formatter is a DateFormatter instance
///     var customDate: Date  // Encoded using custom format
/// }
/// ```
///
/// Available strategies:
/// - `.timeIntervalSince1970`: Seconds since 1970 as Double
/// - `.timeIntervalSince2001`: Seconds since 2001 as Double (same as timeIntervalSinceReferenceDate)
/// - `.secondsSince1970`: Seconds since 1970 as Int64
/// - `.millisecondsSince1970`: Milliseconds since 1970 as Int64
/// - `.iso8601`: ISO8601/RFC3339 formatted string
/// - `.formatted(DateFormatter)`: Custom format using provided formatter
///
/// - Parameter strategy: The strategy to use for date encoding/decoding
@attached(peer)
public macro DateCoding(_ strategy: DateCodingStrategy) = #externalMacro(module: "ReerCodableMacros", type: "DateCoding")
