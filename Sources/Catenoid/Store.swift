// Copyright © Fleuronic LLC. All rights reserved.

public import enum PersistDB.ReadWrite
public import class PersistDB.Store
public import protocol Schemata.AnyModel

import struct Foundation.URL
import class Foundation.FileManager

public extension Store<ReadWrite> {
	static func open(for types: [any AnyModel.Type]) async throws -> Store<ReadWrite> {
		print(try url)
		return try await Self
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
