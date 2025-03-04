// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "todocli",
    products: [
        .executable(name: "todocli", targets: ["todocli"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "todocli", dependencies: [], path: "sources"),
        .testTarget(name: "tests", dependencies: ["todocli"]),
    ]
)
