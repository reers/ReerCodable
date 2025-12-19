[简体中文](README_CN.md)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/reers/ReerCodable)

# ReerCodable
Extension of `Codable` using Swift macros to make serialization simpler with declarative annotations!

```swift
@Codable
@SnakeCase
struct User {
    @CodingKey("user_name")
    var name: String
    
    @KebabCase
    @DateCoding(.iso8601)
    var birthDate: Date
    
    @CodingKey("location.city")
    var city: String
    
    @CustomCoding<Double>(
        decode: { return try $0.value(forKeys: "height_in_meters") * 100.0 },
        encode: { try $0.set($1 / 100.0, forKey: "height_in_meters") }
    )
    var height: Double
}
```

# Overview
ReerCodable framework provides a series of custom macros for generating dynamic Codable implementations. The core of the framework is the @Codable() macro, which generates concrete implementations under data annotations provided by other macros (⚠️ Only the `@Codable` macro can be expanded in XCode macro expansion, expanding other macros will have no response)

The framework has been fully tested using [Swift Testing](https://developer.apple.com/xcode/swift-testing/). 

Main features include:
- Declare custom `CodingKey` values for each property through `@CodingKey("key")`, without writing all `CodingKey` values.
- Support nested `CodingKey` through string expressions, like `@CodingKey("nested.key")`
- Allow using multiple `CodingKey`s for Decode, like `@CodingKey("key1", "key2")`
- Support using `@SnakeCase`, `KebabCase` etc. to mark types or properties for easy naming conversion
- Customize nested containers during Coding using `@CodingContainer`
- Support specified `CodingKey` for Encode, like `EncodingKey("encode_key")`
- Allow using default values when decoding fails to avoid `keyNotFound` errors
- Allow using `@CodingIgnored` to ignore specific properties during encoding/decoding
- Support automatic conversion between base64 strings and `Data` `[UInt8]` types using `@Base64Coding`
- Through `@CompactDecoding`, ignore `null` values when Decoding `Array`, `Dictionary`, `Set` instead of throwing errors
- Support various encoding/decoding of `Date` through `@DateCoding`
- Support custom encoding/decoding logic through `@CustomCoding`
- Better support for subclasses using `@InheritedCodable`
- Provide simple and rich encoding/decoding capabilities for various `enum` types
- Support encoding/decoding lifecycle through `ReerCodableDelegate`, like `didDecode`, `willEncode`
- Provide extensions to support using JSON String, `Dictionary`, `Array` directly as parameters for encoding/decoding
- Support flexible type conversion between basic data types like `Bool`, `String`, `Double`, `Int`, `CGFloat` through `@FlexibleType`
- Support BigInt `Int128`, `UInt128` on macOS 15+, iOS 13+
- Support encoding/decoding of `Any` through `AnyCodable`, like `var dict = [String: AnyCodable]`
- Flatten nested property into the parent structure during coding using `@Flat`
- Auto-generate default instances: 
  Use `@DefaultInstance` to automatically create a default instance of your type, 
  accessible through `Model.default`
- Flexible copying with updates: 
  The `@Copyable` macro generates a powerful `copy()` method that allows both 
  full copies and selective property updates in a single call
- Support the use of `@Decodable` or `@Encodable` alone
- Full compatibility with classes inheriting from `NSObject`

# Requirements
XCode 16.0+

iOS 13.0+, macOS 10.15+, tvOS 13.0+, visionOS 1.0+, watchOS 6.0+

Swift 5.10+

swift-syntax 600.0.0+

# Installation
<details>
<summary>Swift Package Manager</summary>
</br>
<p>You can install ReerCodable using <a href="https://swift.org/package-manager">The Swift Package Manager</a> by adding the proper description to your <code>Package.swift</code> file:</p>
<pre><code class="swift language-swift">import PackageDescription
let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .package(url: "https://github.com/reers/ReerCodable.git", from: "1.4.6")
    ]
)
</code></pre>
<p>Then, add ReerCodable to your targets dependencies like so:</p>
<pre><code class="swift language-swift">.product(name: "ReerCodable", package: "ReerCodable"),</code></pre>
<p>Finally, run <code>swift package update</code>.</p>
</details>

<details>
<summary>CocoaPods</summary>
</br>
<p>Since CocoaPods doesn't directly support Swift Macro, the macro implementation can be compiled into binary for use. The integration method is as follows, requiring <code>s.pod_target_xcconfig</code> to load the binary plugin of macro implementation:</p>
<pre><code class="ruby language-ruby">
Pod::Spec.new do |s|
  s.name             = 'YourPod'
  s.dependency 'ReerCodable', '1.4.6'
  # Copy the following config to your pod
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/ReerCodable/release/ReerCodableMacros-tool#ReerCodableMacros'
  }
end
</code></pre>

<p><strong>⚠️ Important:</strong> If you encounter <code>rsync</code> permission errors with Xcode 14+, disable User Script Sandboxing:</p>
<p>In your project's <strong>Build Settings</strong>, search for <code>User Script Sandboxing</code> and set <code>ENABLE_USER_SCRIPT_SANDBOXING</code> to <code>No</code>. This resolves CocoaPods script execution issues caused by Xcode's stricter sandbox restrictions.</p>

</details>

# Usage

ReerCodable greatly simplifies Swift's serialization process through declarative annotations. Here are detailed examples of each feature:

### 1. Custom CodingKey

Use `@CodingKey` to specify custom keys for properties without manually writing `CodingKeys` enum:

<table>
<tr>
<th>ReerCodable</th>
<th>Codable</th>
</tr>
<tr>
<td>

```swift
@Codable
struct User {
    @CodingKey("user_name")
    var name: String
    
    @CodingKey("user_age")
    var age: Int
    
    var height: Double
}
```

</td>
<td>

```swift
struct User: Codable {
    var name: String
    var age: Int
    var height: Double
    
    enum CodingKeys: String, CodingKey {
        case name = "user_name"
        case age = "user_age"
        case height
    }
}
```

</td>
</tr>
</table>

### 2. Nested CodingKey

Support nested key paths using dot notation:

```swift
@Codable
struct User {
    @CodingKey("other_info.weight")
    var weight: Double
    
    @CodingKey("location.city")
    var city: String
}
```

### 3. Multiple Keys for Decoding

Multiple keys (including nested keys) can be specified for decoding, the system will try decoding in order until successful:

```swift
@Codable
struct User {
    @CodingKey("name", "username", "nick_name", "user_info.name")
    var name: String
}
```

### 4. Name Style Conversion

Support multiple naming style conversions, can be applied to types or individual properties:

```swift
@Codable
@SnakeCase
struct Person {
    var firstName: String  // decoded from "first_name" or encoded to "first_name"
    
    @KebabCase
    var lastName: String   // decoded from "last-name" or encoded to "last-name"
}
```

### 5. Custom Coding Container

Use `@CodingContainer` to customize the container path for encoding and decoding, typically used when dealing with heavily nested JSON structures while wanting the model declaration to directly match a sub-level structure:

<table>
<tr>
<th>ReerCodable</th>
<th>JSON</th>
</tr>
<tr>
<td>

```swift
@Codable
@CodingContainer("data.info")
struct UserInfo {
    var name: String
    var age: Int
}
```

</td>
<td>

```json
{
    "code": 0,
    "data": {
        "info": {
            "name": "phoenix",
            "age": 33
        }
    }
}
```

</td>
</tr>
</table>

### 6. Encoding-Specific Key

Different key names can be specified for the encoding process. Since `@CodingKey` may have multiple parameters, and can use `@SnakeCase`, `KebabCase`, etc., decoding may use multiple keys, then encoding will use the first key, or `@EncodingKey` can be used to specify the key

```swift
@Codable
struct User {
    @CodingKey("user_name")      // decoding uses "user_name", "name"
    @EncodingKey("name")         // encoding uses "name"
    var name: String
}
```

### 7. Default Value Support

Default values can be used when decoding fails. Native `Codable` throws an exception for non-`Optional` properties when the correct value is not parsed, even if an initial value has been set, or even if it's an `Optional` type enum

```swift
@Codable
struct User {
    var age: Int = 33
    var name: String = "phoenix"
    // If the `gender` field in the JSON is neither `male` nor `female`, the native Codable will throw an exception, whereas ReerCodable will not and instead set it to nil. For example, with `{"gender": "other"}`, this scenario might occur when the client has defined an enum but the server has added new fields in a business context.
    var gender: Gender?
}

@Codable
enum Gender: String {
    case male, female
}
```

For explicit control you can annotate properties with `@DecodingDefault`, `@EncodingDefault`, or `@CodingDefault`:

```swift
@Decodable
struct Flags {
    @DecodingDefault(false)
    var isEnabled: Bool
}

@Encodable
struct Payload {
    @EncodingDefault("anonymous")
    var nickname: String?
}

@Codable
struct Preferences {
    @CodingDefault([String]())
    var tags: [String]?
}
```

`@DecodingDefault` supplies a fallback when decoding throws or keys are missing, `@EncodingDefault` encodes the provided expression instead of `nil`, and `@CodingDefault` combines both behaviors with a single annotation.

### 8. Ignore Properties

Use `@CodingIgnored` to ignore specific properties during encoding/decoding. During decoding, non-`Optional` properties must have a default value to satisfy Swift initialization requirements. `ReerCodable` automatically generates default values for basic data types and collection types. For other custom types, users need to provide default values.

```swift
@Codable
struct User {
    var name: String
    
    @CodingIgnored
    var ignore: Set<String>
}
```

### 9. Base64 Coding

Automatically handle conversion between base64 strings and `Data`, `[UInt8]` types:

```swift
@Codable
struct User {
    @Base64Coding
    var avatar: Data
    
    @Base64Coding
    var voice: [UInt8]
}
```

### 10. Collection Type Decoding Optimization

Use `@CompactDecoding` to automatically filter null values when decoding arrays, same meaning as `compactMap`:

```swift
@Codable
struct User {
    @CompactDecoding
    var tags: [String]  // ["a", null, "b"] will be decoded as ["a", "b"]
}
```
At the same time, both `Dictionary` and `Set` also support the use of `@CompactDecoding` for optimization.

### 11. Date Coding

Support various date format encoding/decoding:

<table>
<tr>
<th>ReerCodable</th>
<th>JSON</th>
</tr>
<tr>
<td>

```swift
@Codable
class DateModel {
    @DateCoding(.timeIntervalSince2001)
    var date1: Date
    
    @DateCoding(.timeIntervalSince1970)
    var date2: Date
    
    @DateCoding(.secondsSince1970)
    var date3: Date
    
    @DateCoding(.millisecondsSince1970)
    var date4: Date
    
    @DateCoding(.iso8601)
    var date5: Date
    
    @DateCoding(.iso8601)
    var date6: Date
    
    @DateCoding(.formatted(Self.formatter))
    var date7: Date
    
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'Year'MM'-Month'dd'*Day 'HH'h'mm'm'ss's'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
```

</td>
<td>

```json
{
    "date1": 1431585275,
    "date2": 1731585275.944,
    "date3": 1731585275,
    "date4": 1731585275944,
    "date5": "2024-12-10T00:00:00Z",
    "date6": "2025-04-17T00:00:00.000Z",
    "date7": "2024Year12-Month10*Day 00h00m00s"
}
```

</td>
</tr>
</table>

### 12. Custom Encoding/Decoding Logic

Implement custom encoding/decoding logic through `@CustomCoding`. There are two ways to customize encoding/decoding:
- Through closures, using `decoder: any Decoder`, `encoder: any Encoder` as parameters to implement custom logic:

```swift
@Codable
struct User {
    @CustomCoding<Double>(
        decode: { return try $0.value(forKeys: "height_in_meters") * 100.0 },
        encode: { try $0.set($1 / 100.0, forKey: "height_in_meters") }
    )
    var heightInCentimeters: Double
}
```
- Through a custom type implementing the `CodingCustomizable` protocol to implement custom logic:
```swift
// 1st 2nd 3rd 4th 5th  -> 1 2 3 4 5
struct RankTransformer: CodingCustomizable {
    
    typealias Value = UInt
    
    static func decode(by decoder: any Decoder, keys: [String]) throws -> UInt {
        var temp: String = try decoder.value(forKeys: keys)
        temp.removeLast(2)
        return UInt(temp) ?? 0
    }
    
    static func encode(by encoder: any Encoder, key: String, value: Value) throws {
        try encoder.set(value, forKey: key)
    }
}

@Codable
struct HundredMeterRace {
    @CustomCoding(RankTransformer.self)
    var rank: UInt
}
```
During custom implementation, the framework provides methods that can make encoding/decoding more convenient:
```swift
public extension Decoder {
    func value<Value: Decodable>(forKeys keys: String...) throws -> Value {
        let container = try container(keyedBy: AnyCodingKey.self)
        return try container.decode(type: Value.self, keys: keys)
    }
}

public extension Encoder {
    func set<Value: Encodable>(_ value: Value, forKey key: String, treatDotAsNested: Bool = true) throws {
        var container = container(keyedBy: AnyCodingKey.self)
        try container.encode(value: value, key: key, treatDotAsNested: treatDotAsNested)
    }
}
```

### 13. Inheritance Support

Use `@InheritedCodable` for better support of subclass encoding/decoding. Native `Codable` cannot parse subclass properties, even if the value exists in JSON, requiring manual implementation of `init(from decoder: any Decoder) throws`

```swift
@Codable
class Animal {
    var name: String
}

@InheritedCodable
class Cat: Animal {
    var color: String
}
```

### 14. Enum Support

Provide rich encoding/decoding capabilities for enums:
- Support for basic enum types and RawValue enums
```swift
@Codable
struct User {
    let gender: Gender
    let rawInt: RawInt
    let rawDouble: RawDouble
    let rawDouble2: RawDouble2
    let rawString: RawString
}

@Codable
enum Gender {
    case male, female
}

@Codable
enum RawInt: Int {
    case one = 1, two, three, other = 100
}

@Codable
enum RawDouble: Double {
    case one, two, three, other = 100.0
}

@Codable
enum RawDouble2: Double {
    case one = 1.1, two = 2.2, three = 3.3, other = 4.4
}

@Codable
enum RawString: String {
    case one, two, three, other = "helloworld"
}
```
- Support using `CodingCase(match: ....)` to match multiple values or ranges
```swift
@Codable
enum Phone: Codable {
    @CodingCase(match: .bool(true), .int(10), .string("iphone"), .intRange(22...30))
    case iPhone
    
    @CodingCase(match: .int(12), .string("MI"), .string("xiaomi"), .doubleRange(50...60))
    case xiaomi
    
    @CodingCase(match: .bool(false), .string("oppo"), .stringRange("o"..."q"))
    case oppo
}
```
- For enums with associated values, support using `AssociatedValue` to match associated values, use `.label()` to declare matching logic for labeled associated values, use `.index()` to declare matching logic for unlabeled associated values. `ReerCodable` supports two JSON formats for enum matching
    - The first is also supported by native `Codable`, where the enum value and its associated values have a parent-child structure:
    ```swift
    @Codable
    enum Video: Codable {
        /// {
        ///     "YOUTUBE": {
        ///         "id": "ujOc3a7Hav0",
        ///         "_1": 44.5
        ///     }
        /// }
        @CodingCase(match: .string("youtube"), .string("YOUTUBE"))
        case youTube
        
        /// {
        ///     "vimeo": {
        ///         "ID": "234961067",
        ///         "minutes": 999999
        ///     }
        /// }
        @CodingCase(
            match: .string("vimeo"),
            values: [.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
        )
        case vimeo(id: String, duration: TimeInterval = 33, Int)
        
        /// {
        ///     "tiktok": {
        ///         "url": "https://example.com/video.mp4",
        ///         "tag": "Art"
        ///     }
        /// }
        @CodingCase(
            match: .string("tiktok"),
            values: [.label("url", keys: "url")]
        )
        case tiktok(url: URL, tag: String?)
    }
    ```
    - The second is where enum values and their associated values are at the same level or have custom matching structures, using CaseMatcher with key path for custom path value matching
    ```swift
    @Codable
    enum Video1: Codable {
        /// {
        ///     "type": {
        ///         "middle": "youtube"
        ///     }
        /// }
        @CodingCase(match: .string("youtube", at: "type.middle"))
        case youTube
        
        /// {
        ///     "type": "vimeo",
        ///     "ID": "234961067",
        ///     "minutes": 999999
        /// }
        @CodingCase(
            match: .string("vimeo", at: "type"),
            values: [.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
        )
        case vimeo(id: String, duration: TimeInterval = 33, Int)
        
        /// {
        ///     "type": "tiktok",
        ///     "media": "https://example.com/video.mp4",
        ///     "tag": "Art"
        /// }
        @CodingCase(
            match: .string("tiktok", at: "type"),
            values: [.label("url", keys: "media")]
        )
        case tiktok(url: URL, tag: String?)
    }
    ```

### 15. Lifecycle Callbacks

Support encoding/decoding lifecycle callbacks:

```swift
@Codable
class User {
    var age: Int
    
    func didDecode(from decoder: any Decoder) throws {
        if age < 0 {
            throw ReerCodableError(text: "Invalid age")
        }
    }
    
    func willEncode(to encoder: any Encoder) throws {
        // Process before encoding
    }
}

@Codable
struct Child: Equatable {
    var name: String
    
    mutating func didDecode(from decoder: any Decoder) throws {
        name = "reer"
    }
    
    func willEncode(to encoder: any Encoder) throws {
        print(name)
    }
}

```

### 16. JSON Extension Support

Provide convenient JSON string and dictionary conversion methods:

```swift
let jsonString = "{\"name\": \"Tom\"}"
let user = try User.decoded(from: jsonString)

let dict: [String: Any] = ["name": "Tom"]
let user2 = try User.decoded(from: dict)
```

### 17. Basic Type Conversion

Use `@FlexibleType` to enable automatic conversion between basic data types. This can be applied to both individual properties and entire types:

```swift
@Codable
struct User {
    @FlexibleType
    @CodingKey("is_vip")
    var isVIP: Bool    // Can decode from "1", 1, "true", "yes" as true

    @FlexibleType
    @CodingKey("score")
    var score: Double  // Can decode from "100" or 100 as 100.0
}

@Codable
@FlexibleType
struct Settings {
    // All properties in this type will support flexible type conversion
    var isEnabled: Bool    // Can decode from number or string
    var count: Int        // Can decode from string
    var amount: Double    // Can decode from string or integer
}
```

### 18. AnyCodable Support

Implement encoding/decoding of `Any` type through `AnyCodable`:

```swift
@Codable
struct Response {
    var data: AnyCodable  // Can store data of any type
    var metadata: [String: AnyCodable]  // Equivalent to [String: Any] type
}
```

### 19. Generate Default Instance

```swift
@Codable
@DefaultInstance
struct ImageModel {
    var url: URL
}

@Codable
@DefaultInstance
struct User5 {
    let name: String
    var age: Int = 22
    var uInt: UInt = 3
    var data: Data
    var date: Date
    var decimal: Decimal = 8
    var uuid: UUID
    var avatar: ImageModel
    var optional: String? = "123"
    var optional2: String?
}
```

Will generate the following instance:

```swift
static let `default` = User5(
    name: "",
    age: 22,
    uInt: 3,
    data: Data(),
    date: Date(),
    decimal: 8,
    uuid: UUID(),
    avatar: ImageModel.default,
    optional: "123",
    optional2: nil
)
```

⚠️ Note: Properties with generic types are NOT supported with `@DefaultInstance`
```swift
@Codable
struct NetResponse<Element: Codable> {
    let data: Element?
    let msg: String
    private(set) var code: Int = 0
}
```

### 20. Generate Copy Method
Use `Copyable` to generate `copy` method for models

```swift
@Codable
@Copyable
public struct Model6 {
    var name: String
    let id: Int
    var desc: String?
}

@Codable
@Copyable
class Model7<Element: Codable> {
    var name: String
    let id: Int
    var desc: String?
    var data: Element?
}
```

Generates the following `copy` methods. As you can see, besides default copy, you can also update specific properties:

```swift
public func copy(
    name: String? = nil,
    id: Int? = nil,
    desc: String? = nil
) -> Model6 {
    return .init(
        name: name ?? self.name,
        id: id ?? self.id,
        desc: desc ?? self.desc
    )
}

func copy(
    name: String? = nil,
    id: Int? = nil,
    desc: String? = nil,
    data: Element? = nil
) -> Model7 {
    return .init(
        name: name ?? self.name,
        id: id ?? self.id,
        desc: desc ?? self.desc,
        data: data ?? self.data
    )
}
```

### 20. Use `@Decodable` or `@Encodable` alone

```
@Decodable
struct Item: Equatable {
    let id: Int
}

@Encodable
struct User3: Equatable {
    let name: String
}
```

### 21. Flatten Property with `@Flat`

Flatten a nested property so that its fields are encoded/decoded at the same level as the enclosing type.

```swift
@Codable
struct User {
    var name: String
    var age: Int = 0

    @Flat
    var address: Address
}

@Codable
struct Address {
    var country: String
    var city: String
}

// Input
let dict: [String: Any] = [
    "name": "phoenix",
    "age": 34,
    "country": "China",
    "city": "Beijing"
]

let model = try User.decoded(from: dict)
// model == User(name: "phoenix", age: 34, address: Address(country: "China", city: "Beijing"))
```

### 22. NSObject Subclass Support

`@Codable` fully supports classes that inherit from `NSObject`. The macro automatically detects and correctly handles the `super.init()` call:

```swift
// Direct inheritance from NSObject
@Codable
public class Message: NSObject {
    let title: String
    let content: String
}

// Inheriting from NSObject subclass
@Codable
class Article: NSObject {
    let title: String
    var content: String = ""
}

@InheritedCodable
class NewsArticle: Article {
    let source: String
    var publishDate: String = ""
}
```

All `@Codable` features (such as `@CodingKey`, `@SnakeCase`, `@FlexibleType`, etc.) can be used with `NSObject` subclasses.

These examples demonstrate the main features of ReerCodable, which can help developers greatly simplify the encoding/decoding process, improving code readability and maintainability.
