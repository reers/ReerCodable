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

# Overview
ReerCodable 框架提供了一系列自定义宏，用于生成动态的 Codable 实现。该框架的核心是 @Codable() 宏，它可以在其他宏提供的数据标记下生成具体的实现。

主要包含以下 feature:
- 通过 `@CodingKey("key")` 为每个属性声明自定义的 `CodingKey` 值, 无需编写所有的 `CodingKey` 值.
- 支持通过字符串表达嵌套的 `CodingKey`, 如 `@CodingKey("nested.key")`
- 允许使用多个 `CodingKey` 来进行 Decode, 如 `@CodingKey("key1", "key2")`
- 支持使用 `@SnakeCase`, `KebabCase` 等来标记类型或属性来方便地实现命名转换
- 支持 Encode 时指定的 `CodingKey`, 如 `EncodingKey("encode_key")`
- 允许解码失败时使用默认值, 从而避免 `keyNotFound` 错误发生
- 允许使用 `@CodingIgnored` 在编解码过程中忽略特定属性
- 支持使用 `@Base64Coding` 自动对 base64 字符串和 `Data` `[UInt8]` 类型进行转换
- 在 Decode `Array`, `Dictionary`, `Set` 时, 通过 `@CompactDecoding` 可以忽略 `null` 值, 而不是抛出错误
- 支持通过 `@DateCoding` 实现对 `Date` 的各种编解码
- 支持通过 `@CustomCoding` 实现自定义编解码逻辑
- 对各类 `enum` 提供简单而丰富的编解码能力


# Requirements

# Installation

# Usage

