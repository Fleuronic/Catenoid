// swift-tools-version:6.0
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
		.package(url: "https://github.com/jordanekay/Schemata", branch: "master"),
		.package(url: "https://github.com/jordanekay/PersistDB", branch: "master"),
		.package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", branch: "swift-concurrency")
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
	],
	swiftLanguageModes: [.v6]
)

for target in package.targets {
	target.swiftSettings = [
		.enableUpcomingFeature("ExistentialAny")
	]
}
