// swift-tools-version:5.10
// Copyright © Fleuronic LLC. All rights reserved.

import PackageDescription

let package = Package(
	name: "Catenoid",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "Catenoid",
			targets: ["Catenoid"]
		)
	],
	dependencies: [
        .package(url: "https://github.com/Fleuronic/Catena", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Schemata", branch: "master"),
		.package(url: "https://github.com/Fleuronic/PersistDB", branch: "master")
	],
	targets: [
		.target(
			name: "Catenoid",
			dependencies: [
				"Catena",
				"Schemata",
				"PersistDB"
			]
		)
	]
)
