// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "CoreNetworking",
  products: [
    .library(
      name: "CoreNetworking",
      targets: ["CoreNetworking"]),
  ],
  targets: [
    .target(
      name: "CoreNetworking",
      dependencies: []),
    .testTarget(
      name: "CoreNetworkingTests",
      dependencies: ["CoreNetworking"]),
  ]
)
