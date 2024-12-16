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

/// A macro that customizes the coding path for JSON serialization and deserialization.
///
/// This macro allows you to specify a custom key path for nested JSON structures,
/// making it easier to decode/encode deeply nested JSON objects without writing custom coding logic.
///
/// - Parameters:
///   - keyPath: A dot-notation string representing the path to the actual data in JSON.
///             For example: "data.info" means the actual data is nested under data->info
///   - workForEncoding: A boolean flag indicating whether to apply the container path during encoding.
///                     When true, the encoded JSON will maintain the same nested structure.
///                     Default is false, which means encoding will flatten the structure.
///
/// Example usage:
/// ```swift
/// // JSON Structure:
/// {
///     "code": 0,
///     "data": {
///         "info": {
///             "name": "phoenix",
///             "age": 33
///         }
///     }
/// }
///
/// // Decoding only (flattened encoding)
/// @Codable
/// @CodingContainer("data.info")
/// struct UserInfo {
///     var name: String
///     var age: Int
/// }
///
/// // Decoding and maintaining structure during encoding
/// @Codable
/// @CodingContainer("data.info", workForEncoding: true)
/// struct UserInfo2 {
///     var name: String
///     var age: Int
/// }
///
/// // Usage:
/// let decoder = JSONDecoder()
/// let user = try decoder.decode(UserInfo.self, from: jsonData)
///
/// // When workForEncoding = false (UserInfo):
/// // Encoded result will be: {"name": "phoenix", "age": 33}
///
/// // When workForEncoding = true (UserInfo2):
/// // Encoded result will be:
/// // {
/// //     "data": {
/// //         "info": {
/// //             "name": "phoenix",
/// //             "age": 33
/// //         }
/// //     }
/// // }
/// ```
///
/// Note: This macro must be used in conjunction with @Codable macro
@attached(peer)
public macro CodingContainer(
    _ keyPath: String,
    workForEncoding: Bool = false
) = #externalMacro(module: "ReerCodableMacros", type: "CodingContainer")
