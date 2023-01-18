// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import struct Schemata.None
import protocol Schemata.AnyModel
import protocol Catena.Model

public protocol Database<Store> {
	associatedtype Store

	var store: Store { get }

	static var types: [AnyModel.Type] { get }

	mutating func clear() async throws
}

// MARK: -
public extension Database<PersistDB.Store<ReadWrite>> {
	static func createStore() async throws -> Store {
		try await .open(for: types)
	}
}
