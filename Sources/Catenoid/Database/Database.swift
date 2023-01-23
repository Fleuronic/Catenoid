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

	@discardableResult
	func insert<Model: Catena.Model>(_ model: Model) async -> Result<Model.ID, Never> {
		let id = await store
			.insert(.init(model.identifiedValueSet))
			.asyncStream
			.first { _ in true }!
		return .success(id)
	}

	func fetch<Projection: PersistDB.ModelProjection>(_ query: Query<None, Projection.Model>, returning: Projection.Type) async -> Result<[Projection], Never> {
		let projections: [Projection] = await store.fetch(query)
			.asyncStream
			.first { _ in true }!
			.values
		return .success(projections)
	}

	@discardableResult
	func update<Projection: PersistDB.ModelProjection>(_ predicate: Predicate<Projection.Model>?, using valueSet: ValueSet<Projection.Model>, returning: Projection.Type) async -> Result<[Projection], Never> {
		for await _ in store
			.update(.init(predicate: predicate, valueSet: valueSet))
			.asyncStream {}

		let query = predicate.map(Projection.Model.all.filter) ?? Projection.Model.all
		let results = await fetch(query, returning: Projection.self).value
		return .success(results)
	}

	func delete<Model: Catena.Model>(_ type: Model.Type, with ids: [Model.ID]) async {
		for id in ids {
			for await _ in store
				.delete(.init(\Model.id == id))
				.asyncStream {}
		}
	}
}
