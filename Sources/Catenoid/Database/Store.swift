// Copyright © Fleuronic LLC. All rights reserved.

import Foundation
import PersistDB
import Schemata
import Catena

public extension Store<ReadWrite> {
	static func open(for types: [AnyModel.Type]) async throws -> Store<ReadWrite> {
		print(try url)
		return try await Self
			.open(libraryNamed: .database, for: types)
			.asyncThrowingStream
			.value
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
