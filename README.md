[简体中文](README_CN.md)

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
- Support conversion between basic data types like `Bool`, `String`, `Double`, `Int`, `CGFloat`
- Support encoding/decoding of `Any` through `AnyCodable`, like `var dict = [String: AnyCodable]`

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
        .package(url: "https://github.com/reers/ReerCodable.git", from: "1.0.0")
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
  s.dependency 'ReerCodable', '1.0.0'
  # Copy the following config to your pod
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/Sources/Resources/ReerCodableMacros#ReerCodableMacros'
  }
end
</code></pre>

<p>Alternatively, if not using <code>s.pod_target_xcconfig</code> and <code>s.user_target_xcconfig</code>, you can add the following script in podfile for unified processing:</p>
<pre><code class="ruby language-ruby">
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        rhea_dependency = target.dependencies.find { |d| ['ReerCodable'].include?(d.name) }
        if rhea_dependency
          puts "Adding ReerCodable Swift flags to target: #{target.name}"
          target.build_configurations.each do |config|
            swift_flags = config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
            plugin_flag = '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/Sources/Resources/ReerCodableMacros#ReerCodableMacros'
            unless swift_flags.join(' ').include?(plugin_flag)
              swift_flags.concat(plugin_flag.split)
            end
            config.build_settings['OTHER_SWIFT_FLAGS'] = swift_flags
          end
        end
      end
    end
</code></pre>

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

Multiple keys can be specified for decoding, the system will try decoding in order until successful:

```swift
@Codable
struct User {
    @CodingKey("name", "username", "nick_name")
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

Use `@CodingContainer` to customize container paths during encoding, typically used for root-level model parsing:

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
    // If gender is not included in JSON, native Codable will throw an exception, ReerCodable won't, it will set it to nil
    var gender: Gender?
}

enum Gender {
    case male, female
}
```

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

### 9. Base64 Encoding

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

### 10. Array Decoding Optimization

Use `@CompactDecoding` to automatically filter null values when decoding arrays, same meaning as `compactMap`:

```swift
@Codable
struct User {
    @CompactDecoding
    var tags: [String]  // ["a", null, "b"] will be decoded as ["a", "b"]
}
```

### 11. Date Encoding

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
    
    @DateCoding(.formatted(Self.formatter))
    var date6: Date
    
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
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
    "date6": "2024-12-10T00:00:00.000"
}
```

</td>
</tr>
</table>

### 12. Custom Encoding/Decoding Logic

Implement custom encoding/decoding logic through `@CustomCoding`. There are two ways to customize encoding/decoding:
- Through closures, using `decoder: Decoder`, `encoder: Encoder` as parameters to implement custom logic:

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
    
    static func decode(by decoder: any Decoder) throws -> UInt {
        var temp: String = try decoder.value(forKeys: "rank")
        temp.removeLast(2)
        return UInt(temp) ?? 0
    }
    
    static func encode(by encoder: any Encoder, _ value: UInt) throws {
        try encoder.set(value, forKey: "rank")
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

Use `@InheritedCodable` for better support of subclass encoding/decoding. Native `Codable` cannot parse subclass properties, even if the value exists in JSON, requiring manual implementation of `init(from decoder: Decoder) throws`

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
- For enums with associated values, support using `CaseValue` to match associated values, use `.label()` to declare matching logic for labeled associated values, use `.index()` to declare matching logic for unlabeled associated values. `ReerCodable` supports two JSON formats for enum matching
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
    - The second is where enum values and their associated values are at the same level or have custom matching structures, using `.nested()` for custom path value matching
    ```swift
    @Codable
    enum Video1: Codable {
        /// {
        ///     "type": {
        ///         "middle": "youtube"
        ///     }
        /// }
        @CodingCase(match: .nested("type.middle.youtube"))
        case youTube
        
        /// {
        ///     "type": "vimeo",
        ///     "ID": "234961067",
        ///     "minutes": 999999
        /// }
        @CodingCase(
            match: .nested("type.vimeo"),
            values: [.label("id", keys: "ID", "Id"), .index(2, keys: "minutes")]
        )
        case vimeo(id: String, duration: TimeInterval = 33, Int)
        
        /// {
        ///     "type": "tiktok",
        ///     "media": "https://example.com/video.mp4",
        ///     "tag": "Art"
        /// }
        @CodingCase(
            match: .nested("type.tiktok"),
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
```

### 16. JSON Extension Support

Provide convenient JSON string and dictionary conversion methods:

```swift
let jsonString = "{\"name\": \"Tom\"}"
let user = try User.decode(from: jsonString)

let dict: [String: Any] = ["name": "Tom"]
let user2 = try User.decode(from: dict)
```

### 17. Basic Type Conversion

Support automatic conversion between basic data types:

```swift
@Codable
struct User {
    @CodingKey("is_vip")
    var isVIP: Bool    // "1" or 1 can be decoded as true
    
    @CodingKey("score")
    var score: Double  // "100" or 100 can be decoded as 100.0
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

These examples demonstrate the main features of ReerCodable, which can help developers greatly simplify the encoding/decoding process, improving code readability and maintainability.
