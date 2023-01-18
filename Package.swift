// swift-tools-version:5.7
// Copyright © Fleuronic LLC. All rights reserved.

import PackageDescription

let package = Package(
	name: "Catenoid",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.watchOS(.v6),
		.tvOS(.v13)
	],
	products: [
		.library(
			name: "Catenoid",
			targets: ["Catenoid"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/Fleuronic/Catena", branch: "main")
	],
	targets: [
		.target(
			name: "Catenoid",
			dependencies: [
				"Catena"
			]
		)
	]
)
