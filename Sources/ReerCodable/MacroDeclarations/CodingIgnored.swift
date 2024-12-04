//
//  Copyright 2024 reers.
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

/// The `@CodingIgnored` macro marks a property to be ignored during encoding and decoding.
///
/// When applied to a property in a type marked with `@Codable`, this property will be:
/// - Skipped during encoding (not written to the encoded data)
/// - Skipped during decoding (not read from the encoded data)
/// - Initialized with its default value or nil if optional
///
/// Example usage:
/// ```swift
/// @Codable
/// struct User {
///     let id: String
///     let name: String
///     @CodingIgnored
///     var temporaryCache: [String: Any]? // This property will be ignored during coding
/// }
/// ```
@attached(peer)
public macro CodingIgnored() = #externalMacro(module: "ReerCodableMacros", type: "CodingIgnored")
