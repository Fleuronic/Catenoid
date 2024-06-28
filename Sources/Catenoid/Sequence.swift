// Copyright © Fleuronic LLC. All rights reserved.

public extension Sequence {
	func map<NewElement>(_ transform: (Element) async throws -> NewElement) async rethrows -> [NewElement] {
		var values: [NewElement] = []
		for element in self {
			try await values.append(transform(element))
		}

		return values
	}
}
