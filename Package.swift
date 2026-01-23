// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ReerCodable",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ReerCodable",
            targets: ["ReerCodable"]
        )
    ],
    traits: [
        // AutoFlexibleType trait: When enabled, all @Codable types will automatically
        // support flexible type conversion without needing explicit @FlexibleType annotation.
        // This restores the original automatic type conversion behavior.
        //
        // Usage in your Package.swift:
        // .package(url: "...", traits: ["AutoFlexibleType"])
        .trait(
            name: "AutoFlexibleType",
            description: "Enable automatic type conversion for all @Codable/@Decodable types"
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "ReerCodableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "ReerCodable", dependencies: ["ReerCodableMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "ReerCodableTests",
            dependencies: [
                "ReerCodable",
                "ReerCodableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
