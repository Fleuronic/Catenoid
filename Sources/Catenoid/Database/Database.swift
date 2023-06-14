// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import Catena
import CollectionConcurrencyKit

public protocol Database<Store>: Storage {
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
	@discardableResult
	func insert<Model: Catena.Model>(_ model: Model) async -> Result<Model.ID, Never> {
		.success(await store.insert(.init(model.identifiedValueSet)).value)
	}

	@discardableResult
	func insert<Fields: Catena.Fields>(_ model: Fields.Model, returning fields: Fields.Type) async -> Result<Fields, Never> {
		let id = await insert(model).value
		return await fetch(\.id == id, returning: fields).map(\.first!)
	}

	@discardableResult
	func insert<Model: Catena.Model>(_ models: [Model]) async -> Result<[Model.ID], Never> {
		.success(await models.asyncMap(insert).map(\.value))
	}

	@discardableResult
	func insert<Fields: Catena.Fields>(_ models: [Fields.Model], returning fields: Fields.Type) async -> Result<[Fields], Never> {
		let ids = await insert(models).value
		let predicate = ids.reduce(Fields.Model.all.predicates.first!) {
			$0 || \.id == $1
		}
		return await fetch(predicate, returning: fields)
	}

	func fetch<Model: Catena.Model>(_ type: Model.Type, with id: Model.ID) async -> Result<Model.ID?, Never> {
		await fetch(type, where: \.id == id).map(\.first)
	}

	func fetch<Model: Catena.Model>(_ type: Model.Type, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID], Never> {
		await fetch(predicate, returning: IDFields<Model>.self).map { $0.map(\.id) }
	}

	func fetch<Fields: Catena.Fields>(_ predicate: Predicate<Fields.Model>? = nil, returning fields: Fields.Type) async -> Result<[Fields], Never> {
		let query = predicate.map { Query().filter($0) } ?? Fields.Model.all
		return .success(await store.fetch(query).value.values)
	}

	@discardableResult
	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID], Never> {
		store.update(.init(predicate: predicate, valueSet: valueSet)).start()
		return await fetch(Model.self, where: predicate)
	}

	@discardableResult
	func update<Fields: Catena.Fields>(_ valueSet: ValueSet<Fields.Model>, where predicate: Predicate<Fields.Model>? = nil, returning fields: Fields.Type) async -> Result<[Fields], Never> {
		let _ = await update(valueSet, where: predicate)
		return await fetch(predicate, returning: fields)
	}

	@discardableResult
	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, with id: Model.ID) async -> Result<Model.ID, Never> {
		await update(valueSet, with: id, returning: IDFields<Model>.self).map(\.id)
	}

	@discardableResult
	func update<Fields: Catena.Fields>(_ valueSet: ValueSet<Fields.Model>, with id: Fields.Model.ID, returning fields: Fields.Type) async -> Result<Fields, Never> {
		await update(valueSet, where: \.id == id, returning: fields).map(\.first!)
	}

	@discardableResult
	func delete<Model: Catena.Model>(_ type: Model.Type, where predicate: Predicate<Model>? = nil) async -> Result<Void, Never> {
		store.delete(.init(predicate)).start()
		return .success(())
	}

	@discardableResult
	func delete<Model: Catena.Model>(_ type: Model.Type, with id: Model.ID) async -> Result<Void, Never> {
		await delete(type, where: \.id == id)
	}
}
