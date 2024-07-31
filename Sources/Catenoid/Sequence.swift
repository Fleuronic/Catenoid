// Copyright © Fleuronic LLC. All rights reserved.

public extension Sequence where Element: Sendable {
	func asyncMap<NewElement>(_ transform: (Element) async throws -> NewElement) async rethrows -> [NewElement] {
		var values: [NewElement] = []
		for element in self {
			try await values.append(transform(element))
		}

		return values
	}

	func concurrentMap<NewElement: Sendable>(_ transform: @Sendable @escaping (Element) async throws -> NewElement) async rethrows -> [NewElement] {
		let tasks = map { element in
			Task {
				try await transform(element)
			}
		}

		return try await tasks.asyncMap { task in
			try await task.value
		}
	}
}
