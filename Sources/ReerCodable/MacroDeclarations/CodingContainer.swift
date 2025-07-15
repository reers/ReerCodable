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

/// A macro that simplifies decoding and encoding of deeply nested JSON objects.
///
/// This macro allows you to declare a root path for a `Codable` type, eliminating the need to
/// write boilerplate `init(from:)` and `encode(to:)` methods for navigating nested JSON.
/// It works by instructing the decoder/encoder to treat the JSON inside the `keyPath` as the
/// actual top-level object for this type.
///
/// ---
///
/// ## Usage Guidelines and Limitations
///
/// `@CodingContainer` is a powerful convenience tool, but it should be used judiciously to maintain
/// a clean and reusable codebase.
///
/// - **Intended Use Case:** This macro is designed primarily for **non-reusable, top-level API response models**.
///   Attaching a parent JSON path directly to a model creates a tight coupling between that model and a
///   specific data structure. For reusable core models (e.g., `User`, `Product`), it is strongly recommended
///   to keep them "clean" and instead use the `@CodingKey` macro on the properties of your response model.
///
/// - **Single Path Only:** A type must only be decorated with **one** `@CodingContainer` macro.
///   Applying multiple `CodingContainer` macros to the same type is not supported and will lead to
///   a compile-time error.
///
/// - **Dictionary Path Navigation:** The `keyPath` must represent a navigation path through
///   nested dictionaries (JSON objects). It **does not support indexing into JSON arrays**
///   (e.g., a path like `"data.users[0]"` is invalid).
///
/// ---
///
/// - Parameters:
///   - keyPath: A dot-notation string representing the path to the target data in the JSON.
///             For example, `"data.info"` instructs the decoder to look for the model's data
///             within the `info` object, which is itself inside the `data` object.
///   - workForEncoding: A boolean flag indicating whether to apply the container path during encoding.
///                     When `true`, the encoded JSON will be wrapped within the same nested structure.
///                     Defaults to `false`, which means encoding will produce a "flattened" JSON object
///                     containing only the model's properties.
///
/// ## Example
///
/// ```swift
/// // Given this JSON structure:
/// // {
/// //     "code": 0,
/// //     "data": {
/// //         "info": {
/// //             "name": "phoenix",
/// //             "age": 33
/// //         }
/// //     }
/// // }
///
/// // --- Decoding Example ---
/// @Codable
/// @CodingContainer("data.info")
/// struct UserInfo {
///     var name: String
///     var age: Int
/// }
///
/// // The decoder will automatically look inside "data.info"
/// let user = try JSONDecoder().decode(UserInfo.self, from: jsonData)
/// print(user.name) // "phoenix"
///
/// // --- Encoding Example ---
/// @Codable
/// @CodingContainer("data.info", workForEncoding: true)
/// struct UserInfoForEncoding {
///     var name: String
///     var age: Int
/// }
///
/// let userToEncode = UserInfoForEncoding(name: "reer", age: 1)
/// let encodedData = try JSONEncoder().encode(userToEncode)
/// // Resulting JSON: {"data":{"info":{"name":"reer","age":1}}}
///
/// // If workForEncoding were false (the default):
/// // Resulting JSON: {"name":"reer","age":1}
/// ```
///
/// - Note: This macro must be used on a type that is also annotated with `@Codable`.
@attached(peer)
public macro CodingContainer(
    _ keyPath: String,
    workForEncoding: Bool = false
) = #externalMacro(module: "ReerCodableMacros", type: "CodingContainer")
