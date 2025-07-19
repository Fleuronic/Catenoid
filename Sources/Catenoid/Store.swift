// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import Foundation

public extension Store<ReadWrite> {
	static func open(with name: String, for types: [any AnyModel.Type]) async throws -> Store<ReadWrite> {
		try await Self
			.open(libraryNamed: name, for: types)
			.asyncThrowingStream
			.value!
	}

	static func destroy(with name: String) throws {
		try FileManager.default.removeItem(at: url(with: name))
	}
}

// MARK: -
private extension Store {
	static func url(with name: String) throws -> URL {
		try FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			.appendingPathComponent(name)
	}
}
