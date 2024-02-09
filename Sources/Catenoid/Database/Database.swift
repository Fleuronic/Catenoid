// Copyright © Fleuronic LLC. All rights reserved.

import Catena
import Schemata
import PersistDB
import CollectionConcurrencyKit

public protocol Database<Store>: Storage {
	associatedtype Store

	var store: Store { get }

	static var types: [AnyModel.Type] { get }

	mutating func clear() async throws
}

// MARK: -
public extension Database<PersistDB.Store<ReadWrite>> {
	typealias Result<Resource> = Swift.Result<Resource, Never>

	static func createStore() async throws -> Store {
		try await .open(for: types)
	}

	// MARK: Storage
	func insert<Model: Catena.Model>(_ model: Model) async -> Result<Model.ID> {
		let valueSet = model.valueSet.update(with: [Model.idKeyPath == model.id])
		return .success(await store.insert(.init(valueSet)).value)
	}

	func insert<Model: Catena.Model>(_ models: [Model]) async -> Result<[Model.ID]> {
		.success(await models.asyncMap(insert).map(\.value))
	}

	func fetch<Fields: Catena.Fields>(_ fields: Fields.Type, where predicate: Predicate<Fields.Model>? = nil) async -> Result<[Fields]> {
		let query = predicate.map { Query().filter($0) } ?? Fields.Model.all
		return .success(await store.fetch(query).value.values)
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID]> where StorageError == Never {
		await store.update(.init(predicate: predicate, valueSet: valueSet)).complete()
		return await fetch(where: predicate)
	}

	func delete<Model: Catena.Model>(_ type: Model.Type, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID]> where StorageError == Never {
		await store.delete(.init(predicate)).complete()
		return await fetch(where: predicate)
	}
}
