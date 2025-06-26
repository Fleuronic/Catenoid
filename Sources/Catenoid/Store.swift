// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import Foundation

public extension Store<ReadWrite> {
	static func open(for types: [any AnyModel.Type]) async throws -> Store<ReadWrite> {
		try await Self
			.open(libraryNamed: .database, for: types)
			.asyncThrowingStream
			.value!
	}

	static func destroy() throws {
		try FileManager.default.removeItem(at: url)
	}
}

// MARK: -
private extension Store {
	static var url: URL {
		get throws {
			try FileManager.default
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				.appendingPathComponent(.database)
		}
	}
}

// MARK: -
private extension String {
	static let database = "Database"
}
