// swift-tools-version:5.1
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
	dependencies: [],
	targets: [
		.target(
			name: "Catenoid",
			dependencies: []
		)
	]
)
