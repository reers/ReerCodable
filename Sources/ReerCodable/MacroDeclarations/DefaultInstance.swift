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

/// A macro that automatically generates a default instance for a type.
///
/// The `@DefaultInstance` macro generates a static `default` property that returns
/// an instance with default values for all properties. It works with:
///
/// - Structs and classes with `@Codable`
/// - Enums with `@Codable`
/// - Properties with basic Swift types
/// - Optional properties
/// - Custom types that also use `@DefaultInstance`
///
/// # Default Values for Basic Types:
/// - String: `""`
/// - Int/UInt/Double/Float types: `0` (or specified default)
/// - Bool: `false`
/// - URL: `URL(string: "/")!`
/// - Date: `Date()`
/// - Data: `Data()`
/// - UUID: `UUID()`
/// - Decimal: `0` (or specified default)
/// - Optional: `nil` (or specified default)
///
/// # Examples:
/// ```swift
/// @Codable
/// @DefaultInstance
/// struct ImageModel {
///     var url: URL  // defaults to URL(string: "/")!
/// }
///
/// @Codable
/// @DefaultInstance
/// struct User {
///     let name: String      // defaults to ""
///     var age: Int = 22     // uses specified default
///     var avatar: ImageModel // uses ImageModel.default
///     var optional: String? // defaults to nil
/// }
///
/// @Codable
/// @DefaultInstance
/// enum Video {
///     case tiktok(url: URL, id: Int = 56)
///     case youtube
///     // defaults to first case with default values
/// }
/// ```
///
/// # Custom Default Values:
/// You can override the default implementation by providing your own:
/// ```swift
/// @Codable
/// enum CustomEnum {
///     case a, b
///     static let `default` = Self.b  // custom default
/// }
/// ```
///
/// # Requirements:
/// - Must be used with `@Codable` macro
/// - All properties must have default values or be defaultable types
///
/// # Note:
/// - For enums with associated values, it uses the first case with all default values
/// - For enums without associated values, it uses the first case
/// - Custom `default` implementations take precedence over generated ones
///
/// - Throws: `MacroError` if used without `@Codable` macro
///
@attached(peer)
public macro DefaultInstance() = #externalMacro(module: "ReerCodableMacros", type: "DefaultInstance")
