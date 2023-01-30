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

public extension Database<PersistDB.Store<ReadWrite>> {
	func insert<Model: Catena.Model>(_ model: Model) async -> Model.ID {
		await store.insert(.init(model.identifiedValueSet)).value
	}

	func fetch<Projection: PersistDB.ModelProjection>(_ query: Query<None, Projection.Model>, returning: Projection.Type) async -> [Projection] {
		await store.fetch(query).value.values
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>?) async {
		await store.update(.init(predicate: predicate, valueSet: valueSet)).value
	}

	func delete<Model: Catena.Model>(_ type: Model.Type, with id: Model.ID) async {
		await store.delete(.init(\Model.id == id)).value
	}
}
