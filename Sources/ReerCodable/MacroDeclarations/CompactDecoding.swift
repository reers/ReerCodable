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

/// The `@CompactDecoding` macro filters out nil values during decoding, similar to `compactMap`.
///
/// This macro can be applied to collection types:
/// - Array
/// - Dictionary
/// - Set
///
/// When decoding, any nil or failed-to-decode elements will be automatically removed
/// from the final collection, instead of causing a decoding error.
///
/// Example usage:
/// ```swift
/// @Codable
/// struct Response {
///     @CompactDecoding
///     var items: [Item]  // JSON: [{"id": 1}, null, {"id": 2}, {"invalid": true}] -> Result: [Item(id: 1), Item(id: 2)]
///     
///     @CompactDecoding
///     var dict: [String: User]  // JSON: {"a": {"name": "Alice"}, "b": null, "c": {"invalid": true}} -> Result: ["a": User(name: "Alice")]
///     
///     @CompactDecoding
///     var uniqueIds: Set<String>  // JSON: ["a", null, "b", "a"] -> Result: Set(["a", "b"])
/// }
/// ```
@attached(peer)
public macro CompactDecoding() = #externalMacro(module: "ReerCodableMacros", type: "CompactDecoding")
