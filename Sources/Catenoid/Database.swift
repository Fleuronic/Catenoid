// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB

import struct Catena.IDFields
import struct Identity.Identifier
import protocol Catena.Fields
import protocol Catena.ResultProviding
import protocol Schemata.AnyModel
import protocol Identity.Identifiable

public protocol Database<Store>: ResultProviding, Sendable where Error == Never {
	associatedtype Store

	var store: Store { get }

	static var types: [any AnyModel.Type] { get }

	mutating func clear() async throws
}

// MARK: -
public extension Database<Store<ReadWrite>> {
	static func createStore() async throws -> Store {
		try await .open(for: types)
	}

	func fetch<Fields: Catenoid.Fields>() async -> Results<Fields> {
		await fetch(where: nil)
	}

	func fetch<Fields: Catenoid.Fields>(with id: Fields.Model.ID) async -> SingleResult<Fields> {
		let result: Results<Fields> = await fetch(where: Fields.Model.idKeyPath == id)
		return result.map(\.first!)
	}

	func fetch<Fields: Catenoid.Fields>(with ids: [Fields.Model.ID]) async -> Results<Fields> {
		await fetch(where: ids.contains(Fields.Model.idKeyPath))
	}

	// MARK: Storage
	func insert<Model: Catenoid.Model>(_ model: Model) async -> SingleResult<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		var valueSet = model.valueSet
		if let id = model.identifiedModelID {
			valueSet = valueSet.update(with: [Model.IdentifiedModel.idKeyPath == id])
		}

		return await .success(store.insert(.init(valueSet)).value!)
	}

	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Results<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		await .success(models.map { await insert($0).value })
	}

	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>? = nil) async -> Results<Fields> {
		let query = Query(
			predicates: predicate.map { [$0] } ?? [],
			order: [],
			groupedBy: .init(.init(Fields.Model.idKeyPath))
		)

		guard let resultSet: ResultSet<Fields.Model.ID, Fields> = await store.fetch(query).value else {
			return .success([])
		}

		let values = resultSet.groups.map { group in
			let values = group.values
			let fields = values.first!
			return values.count > 1 ? values.dropFirst().reduce(fields, Fields.merge) : fields
		}

		return .success(values)
	}

	func delete<Model: PersistDB.Model & Identifiable>(where predicate: Predicate<Model>? = nil) async -> Results<Model.ID> where Model.RawIdentifier: Sendable {
		let fields: Results<IDFields<Model>> = await fetch(where: predicate)

		await store.delete(.init(predicate)).complete()
		return fields.map { $0.map(\.id) }
	}
}

