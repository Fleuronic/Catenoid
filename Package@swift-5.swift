// swift-tools-version:5.9
// Copyright © Fleuronic LLC. All rights reserved.

import PackageDescription

let package = Package(
	name: "Catenoid",
	platforms: [
		.iOS(.v13),
		.macOS(.v12),
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
		.package(url: "https://github.com/Fleuronic/PersistDB", branch: "master"),
		.package(url: "https://github.com/Fleuronic/ReactiveSwift", branch: "main")
	],
	targets: [
		.target(
			name: "Catenoid",
			dependencies: [
				"Catena",
				"Schemata",
				"PersistDB",
				"ReactiveSwift"
			]
		)
	]
)

for target in package.targets {
	target.swiftSettings = [
		.enableUpcomingFeature("StrictConcurrency"),
		.enableExperimentalFeature("AccessLevelOnImport")
	]
}
