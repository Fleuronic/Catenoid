// Copyright © Fleuronic LLC. All rights reserved.

import Foundation
import PersistDB
import Schemata
import Catena

public extension Store<ReadWrite> {
	static func open(for types: [AnyModel.Type]) async throws -> Store<ReadWrite> {
		try await Self
			.open(libraryNamed: .database, for: types)
			.asyncThrowingStream
			.first { _ in true }!
	}

	static func destroy() throws {
		try FileManager.default.removeItem(at: url)
	}
}

// MARK: -
private extension Store {
	static var url: URL {
		get throws {
			print(try FileManager.default
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				.appendingPathComponent(.database))
			return try FileManager.default
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				.appendingPathComponent(.database)
		}
	}
}

// MARK: -
private extension String {
	static let database = "Database"
}
