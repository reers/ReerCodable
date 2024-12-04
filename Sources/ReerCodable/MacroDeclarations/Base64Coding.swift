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

/// The `@Base64Coding` macro that provides automatic Base64 encoding and decoding functionality.
///
/// This macro can be applied to properties of type `Data` or `[UInt8]` to automatically handle
/// Base64 string conversion during encoding and decoding:
/// - When decoding: converts Base64 encoded strings to `Data` or `[UInt8]`
/// - When encoding: converts `Data` or `[UInt8]` to Base64 encoded strings
///
/// Example usage:
/// ```swift
/// @Codable
/// struct User {
///     @Base64Coding
///     var data: Data?          // Stored as Base64 string in JSON
///
///     @Base64Coding
///     var bytes: [UInt8]?      // Stored as Base64 string in JSON
/// }
/// ```
///
/// The macro can be combined with other property wrappers like `@CodingKey`:
/// ```swift
/// @CodingKey("data.data2")
/// @Base64Coding
/// var data2: Data?
/// ```
@attached(peer)
public macro Base64Coding() = #externalMacro(module: "ReerCodableMacros", type: "Base64Coding")
