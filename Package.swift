// swift-tools-version:5.7
// Copyright © Fleuronic LLC. All rights reserved.

import PackageDescription

let package = Package(
	name: "Catenoid",
	platforms: [
		.iOS(.v12),
		.macOS(.v10_13),
		.watchOS(.v6),
		.tvOS(.v12)
	],
	products: [
		.library(
			name: "Catenoid",
			targets: ["Catenoid"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/Fleuronic/Catena", branch: "main"),
		.package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git", from: "0.1.0")
	],
	targets: [
		.target(
			name: "Catenoid",
			dependencies: [
				"Catena",
				"CollectionConcurrencyKit"
			]
		)
	]
)
