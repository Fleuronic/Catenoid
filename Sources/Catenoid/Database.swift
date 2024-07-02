// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Catena.IDFields
import protocol Catena.Fields
import protocol Schemata.AnyModel

public protocol Database<Store>: Storage, Sendable where StorageError == Never {
	associatedtype Store

	var store: Store { get }

	static var types: [AnyModel.Type] { get }

	mutating func clear() async throws
}

// MARK: -
public extension Database<Store<ReadWrite>> {
	typealias Result<Resource> = Swift.Result<Resource, StorageError>

	static func createStore() async throws -> Store {
		try await .open(for: types)
	}

	// MARK: Storage
	func insert<Model: Catenoid.Model>(_ model: Model) async -> Result<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		let valueSet = model.valueSet.update(with: [Model.IdentifiedModel.idKeyPath == model.id])
		return await .success(store.insert(.init(valueSet)).value)
	}

	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>? = nil) async -> Result<[Fields]> {
		let query = predicate.map { Query().filter($0) } ?? Fields.Model.all
		return await .success(store.fetch(query).value.values)
	}

	func delete<Model: Catenoid.Model>(_ type: Model.Type, where predicate: Predicate<Model.IdentifiedModel>? = nil) async -> Result<[Model.ID]> where Model.ID == Model.IdentifiedModel.ID {
		await store.delete(.init(predicate)).complete()
		let fields: Result<[IDFields<Model.IdentifiedModel>]> = await fetch(where: predicate)
		return fields.map { $0.map(\.id) }
	}
}
