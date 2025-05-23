// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Catena.IDFields
import struct Schemata.Projection
import struct Identity.Identifier
import protocol Catena.Fields
import protocol Catena.ResultProviding
import protocol Schemata.AnyModel
import protocol Identity.Identifiable

public protocol Database<Store>: Storage, ResultProviding, Sendable where Error == StorageError, StorageError == Never {
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

	// MARK: Storage
	@Sendable func insert<Model: Catenoid.Model>(_ model: Model) async -> SingleResult<Model> where Model.ID == Model.IdentifiedModel.ID {
		let valueSet = model.valueSet.update(with: [Model.IdentifiedModel.idKeyPath == model.id])
		return await .success(store.insert(.init(valueSet)).map { _ in model }.value!)
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

	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type) async -> Result<[Model.ID], StorageError> where Model.RawIdentifier: Sendable {
		await delete(Model.self, with: nil)
	}

	func delete<Model: PersistDB.Model & Identifiable>(with ids: [Identifier<Model>]) async -> Result<[Model.ID], StorageError> where Model.RawIdentifier: Sendable {
		await delete(Model.self, with: ids)
	}
}

// MARK: -
private extension Database<Store<ReadWrite>> {
	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type, with ids: [Model.ID]?) async -> Results<Model.ID> where Model.RawIdentifier: Sendable {
		if let ids, ids.isEmpty {
			return .success([])
		}

		let predicate = ids.map { $0.contains(Model.idKeyPath) }
		let fields: Results<IDFields<Model>> = await fetch(where: predicate)

		await store.delete(.init(predicate)).complete()
		return fields.map { $0.map(\.id) }
	}
}
