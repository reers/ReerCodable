# ReerCodable
使用 Swift macros 对 `Codable` 进行扩展, 以声明式注解让序列化变得更简单!
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

# 概述
ReerCodable 框架提供了一系列自定义宏，用于生成动态的 Codable 实现。该框架的核心是 @Codable() 宏，它可以在其他宏提供的数据标记下生成具体的实现(⚠️ 在 XCode 中进行宏展开时也只能展开 `@Cdable` 宏, 展开其他宏是没有响应的)

主要包含以下 feature:
- 通过 `@CodingKey("key")` 为每个属性声明自定义的 `CodingKey` 值, 无需编写所有的 `CodingKey` 值.
- 支持通过字符串表达嵌套的 `CodingKey`, 如 `@CodingKey("nested.key")`
- 允许使用多个 `CodingKey` 来进行 Decode, 如 `@CodingKey("key1", "key2")`
- 支持使用 `@SnakeCase`, `KebabCase` 等来标记类型或属性来方便地实现命名转换
- 通过使用 `@CodingContainer` 自定义 Coding 时的嵌套容器 
- 支持 Encode 时指定的 `CodingKey`, 如 `EncodingKey("encode_key")`
- 允许解码失败时使用默认值, 从而避免 `keyNotFound` 错误发生
- 允许使用 `@CodingIgnored` 在编解码过程中忽略特定属性
- 支持使用 `@Base64Coding` 自动对 base64 字符串和 `Data` `[UInt8]` 类型进行转换
- 在 Decode `Array`, `Dictionary`, `Set` 时, 通过 `@CompactDecoding` 可以忽略 `null` 值, 而不是抛出错误
- 支持通过 `@DateCoding` 实现对 `Date` 的各种编解码
- 支持通过 `@CustomCoding` 实现自定义编解码逻辑
- 通过使用 `@InheritedCodable` 对子类有更好的支持
- 对各类 `enum` 提供简单而丰富的编解码能力
- 支持通过 `ReerCodableDelegate` 来编解码生命周期, 如 `didDecode`, `willEncode`
- 提供扩展, 支持使用 JSON String, `Dictionary`, `Array` 直接作为参数进行编解码
- 支持 `Bool`, `String`, `Double`, `Int`, `CGFloat` 等基本数据类型互相转换
- 支持通过 `AnyCodable` 来实现对 `Any` 的编解码, 如 `var dict = [String: AnyCodable]`


# 环境要求
XCode 16.0+

iOS 13.0+, macOS 10.15+, tvOS 13.0+, visionOS 1.0+, watchOS 6.0+

Swift 5.10+

swift-syntax 600.0.0+

# 安装
<details>
<summary>Swift Package Manager</summary>
</br>
<p>你可以使用 <a href="https://swift.org/package-manager">The Swift Package Manager</a> 来安装 ReerCodable，请在你的 <code>Package.swift</code> 文件中添加正确的描述:</p>
<pre><code class="swift language-swift">import PackageDescription
let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .package(url: "https://github.com/reers/ReerCodable.git", from: "1.0.1")
    ]
)
</code></pre>
<p>接下来，将 <code>ReerCodable</code> 添加到您的 targets 依赖项中，如下所示:</p>
<pre><code class="swift language-swift">.product(name: "ReerCodable", package: "ReerCodable"),</code></pre>
<p>然后运行 <code>swift package update</code>。</p>
</details>

<details>
<summary>CocoaPods</summary>
</br>
<p>由于 CocoaPods 不支持直接使用 Swift Macro, 可以将宏实现编译为二进制提供使用, 接入方式如下, 需要设置<code>s.pod_target_xcconfig</code>来加载宏实现的二进制插件:</p>
<pre><code class="ruby language-ruby">
Pod::Spec.new do |s|
  s.name             = 'YourPod'
  s.dependency 'ReerCodable', '1.0.1'
  # 复制以下 config 到你的 pod
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -load-plugin-executable -Xfrontend ${PODS_ROOT}/ReerCodable/Sources/Resources/ReerCodableMacros#ReerCodableMacros'
  }
end
</code></pre>

<p>或者, 如果不使用<code>s.pod_target_xcconfig</code>和<code>s.user_target_xcconfig</code>, 也可以在 podfile 中添加如下脚本统一处理:</p>
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

# 使用

ReerCodable 通过声明式注解大大简化了 Swift 的序列化过程。以下是各个特性的详细使用示例：

### 1. 自定义 CodingKey

通过 `@CodingKey` 可以为属性指定自定义 key，无需手动编写 `CodingKeys` 枚举：

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

### 2. 嵌套 CodingKey

支持通过点语法表示嵌套的 key path：

```swift
@Codable
struct User {
    @CodingKey("other_info.weight")
    var weight: Double
    
    @CodingKey("location.city")
    var city: String
}
```

### 3. 多键解码

可以指定多个 key 用于解码，系统会按顺序尝试解码直到成功：

```swift
@Codable
struct User {
    @CodingKey("name", "username", "nick_name")
    var name: String
}
```

### 4. 命名转换

支持多种命名风格转换，可以应用在类型或单个属性上：

```swift
@Codable
@SnakeCase
struct Person {
    var firstName: String  // 从 "first_name" 解码, 或编码为 "first_name"
    
    @KebabCase
    var lastName: String   // 从 "last-name" 解码, 或编码为 "last-name"
}
```

### 5. 自定义编码容器

使用 `@CodingContainer` 自定义编码时的容器路径, 通常用于根层级的 model 解析：

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

### 6. 编码专用 key

可以为编码过程指定不同的键名, 由于 `@CodingKey` 可能有多个参数, 再加上可以使用 `@SnakeCase`, `KebabCase` 等, 解码可能使用多个 key, 那编码时会采用第一个 key, 也可以通过 `@EncodingKey` 来指定 key

```swift
@Codable
struct User {
    @CodingKey("user_name")      // 解码使用 "user_name", "name"
    @EncodingKey("name")         // 编码使用 "name"
    var name: String
}
```

### 7. 默认值支持

解码失败时可以使用默认值, 原生 `Codable` 针对非 `Optional` 属性, 会在没有解析到正确值是抛出异常, 即使已经设置了初始值, 或者即使是 `Optional` 类型的枚举

```swift
@Codable
struct User {
    var age: Int = 33
    var name: String = "phoenix"
    // 若 JSON 中不包含 gender, 原生 Codable 会抛出异常, ReerCodable 不会, 会设置其为 nil
    var gender: Gender?
}

enum Gender {
    case male, female
}
```

### 8. 忽略属性

使用 `@CodingIgnored` 在编解码过程中忽略特定属性. 在解码过程中对于非 `Optional` 属性要有一个默认值才能满足 Swift 初始化的要求, `ReerCodable` 对基本数据类型和集合类型会自动生成默认值, 如果是其他自定义类型, 则需用用户提供默认值.

```swift
@Codable
struct User {
    var name: String
    
    @CodingIgnored
    var ignore: Set<String>
}
```

### 9. Base64 编码

自动处理 base64 字符串与 `Data`, `[UInt8]` 类型的转换：

```swift
@Codable
struct User {
    @Base64Coding
    var avatar: Data
    
    @Base64Coding
    var voice: [UInt8]
}
```

### 10. 数组解码优化

使用 `@CompactDecoding` 在解码数组时自动过滤 null 值, 与 `compactMap` 是同样的意思:

```swift
@Codable
struct User {
    @CompactDecoding
    var tags: [String]  // ["a", null, "b"] 将被解码为 ["a", "b"]
}
```

### 11. 日期编码

支持多种日期格式的编解码：

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

### 12. 自定义编解码逻辑

通过 `@CustomCoding` 实现自定义的编解码逻辑. 自定义编解码有两种方式:
- 通过闭包, 以 `decoder: Decoder`, `encoder: Encoder` 为参数来实现自定义逻辑:

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
- 通过一个实现 `CodingCustomizable` 协议的自定义类型来实现自定义逻辑:
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
自定义实现过程中, 框架提供的方法也可以是编解码更加方便:
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

### 13. 继承支持

使用 `@InheritedCodable` 更好地支持子类的编解码. 原生 `Codable` 无法解析子类属性, 即使 JSON 中存在该值, 需要手动实现 `init(from decoder: Decoder) throws`

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

### 14. 枚举支持

为枚举提供丰富的编解码能力：
- 对基本枚举类型, 以及 RawValue 枚举支持
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
- 支持使用 `CodingCase(match: ....)` 来匹配多个值或 range
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
- 对于有关联值的枚举, 支持通用 `CaseValue` 来匹配关联值, 使用 `.label()` 来声明有标签的关联值的匹配逻辑, 使用 `.index()` 来声明没有标签的的关联值的匹配逻辑. `ReerCodable` 支持两种JSON 格式的枚举匹配
    - 第一种是也是原生 `Codable` 支持的, 即枚举值和其关联值是父子级的结构:
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
    - 第二种是枚举值和其关联值同级或自定义匹配的结构, 使用 `.nested()` 进行自定义路径值的匹配
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

### 15. 生命周期回调

支持编解码的生命周期回调：

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
        // 在编码前进行处理
    }
}
```

### 16. JSON 扩展支持

提供便捷的 JSON 字符串和字典转换方法：

```swift
let jsonString = "{\"name\": \"Tom\"}"
let user = try User.decode(from: jsonString)

let dict: [String: Any] = ["name": "Tom"]
let user2 = try User.decode(from: dict)
```

### 17. 基本类型转换

支持基本数据类型之间的自动转换：

```swift
@Codable
struct User {
    @CodingKey("is_vip")
    var isVIP: Bool    // "1" 或 1 都可以被解码为 true
    
    @CodingKey("score")
    var score: Double  // "100" 或 100 都可以被解码为 100.0
}
```

### 18. AnyCodable 支持

通过 `AnyCodable` 实现对 `Any` 类型的编解码：

```swift
@Codable
struct Response {
    var data: AnyCodable  // 可以存储任意类型的数据
    var metadata: [String: AnyCodable]  // 相当于[String: Any]类型
}
```

以上示例展示了 ReerCodable 的主要特性，这些特性可以帮助开发者大大简化编解码过程，提高代码的可读性和可维护性。
