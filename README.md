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

# Requirements

# Installation

# Usage

