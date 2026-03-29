// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "NextNavigator",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "NextNavigator",
      targets: ["NextNavigator"]),
  ],
  targets: [
    .target(
      name: "NextNavigator",
      dependencies: []),
    .testTarget(
      name: "NextNavigatorTests",
      dependencies: ["NextNavigator"]),
  ])
