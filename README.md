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
        .package(url: "https://github.com/reers/ReerCodable.git", from: "1.0.0")
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
  s.dependency 'ReerCodable', '1.0.0'
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

