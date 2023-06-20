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
    typealias Result<Resource> = Swift.Result<Resource, Never>
    
	func insert<Model: Catena.Model>(_ model: Model) async -> Result<Model.ID> {
		.success(await store.insert(.init(model.identifiedValueSet)).value)
	}

	func insert<Fields: Catena.Fields>(_ model: Fields.Model, returning fields: Fields.Type) async -> Result<Fields> {
		let id = await insert(model).value
		return await fetch(fields, where: Fields.Model.idKeyPath == id).map(\.first!)
	}

	func insert<Model: Catena.Model>(_ models: [Model]) async -> Result<[Model.ID]> {
		.success(await models.asyncMap(insert).map(\.value))
	}

	func insert<Fields: Catena.Fields>(_ models: [Fields.Model], returning fields: Fields.Type) async -> Result<[Fields]> {
		let ids = await insert(models).value
		let predicate = ids.reduce(Fields.Model.all.predicates.first!) {
			$0 || Fields.Model.idKeyPath == $1
		}
		return await fetch(fields, where: predicate)
	}

	func fetch<Model: Catena.Model>(where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID]> {
		await fetch(IDFields<Model>.self, where: predicate).map { $0.map(\.id) }
	}

	func fetch<Fields: Catena.Fields>(_ fields: Fields.Type, where predicate: Predicate<Fields.Model>? = nil) async -> Result<[Fields]> {
		let query = predicate.map { Query().filter($0) } ?? Fields.Model.all
		return .success(await store.fetch(query).value.values)
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID]> {
        await store.update(.init(predicate: predicate, valueSet: valueSet)).map { _ in }.value
		return await fetch(where: predicate)
	}

	func update<Fields: Catena.Fields>(_ valueSet: ValueSet<Fields.Model>, where predicate: Predicate<Fields.Model>? = nil, returning fields: Fields.Type) async -> Result<[Fields]> {
        await update(valueSet, where: predicate).asyncFlatMap { _ in
			await fetch(fields, where: predicate)
        }
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, with id: Model.ID) async -> Result<Model.ID> {
		await update(valueSet, with: id, returning: IDFields<Model>.self).map(\.id)
	}

	func update<Fields: Catena.Fields>(_ valueSet: ValueSet<Fields.Model>, with id: Fields.Model.ID, returning fields: Fields.Type) async -> Result<Fields> {
		await update(valueSet, where: Fields.Model.idKeyPath == id, returning: fields).map(\.first!)
	}

	func delete<Model: Catena.Model>(_ type: Model.Type, where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID]> {
        store.delete(.init(predicate)).start()
        return await fetch(where: predicate)
	}

    func delete<Model: Catena.Model>(_ type: Model.Type, with id: Model.ID) async -> Result<Model.ID?> {
        await delete(type, where: \Model.id == id).map(\.first)
	}
    
    static func createStore() async throws -> Store {
        try await .open(for: types)
    }
}
