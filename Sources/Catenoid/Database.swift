// Copyright © Fleuronic LLC. All rights reserved.

public import PersistDB

public import struct Schemata.Projection
public import protocol Schemata.AnyModel
public import protocol Identity.Identifiable

public import struct Catena.IDFields
public import protocol Catena.Fields

public protocol Database<Store>: Storage, Sendable where StorageError == Never {
	associatedtype Store

	var store: Store { get }

	static var types: [any AnyModel.Type] { get }

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
		return await .success(store.insert(.init(valueSet)).value!/* ?? model.id*/)
	}

	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>? = nil) async -> Result<[Fields]> {
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

	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type, with ids: [Model.ID]? = nil) async -> Result<[Model.ID]> where Model.RawIdentifier: Sendable {
		if let ids, ids.isEmpty {
			return .success([])
		}

		let predicate = ids.map { $0.contains(Model.idKeyPath) }
		await store.delete(.init(predicate)).complete()

		let fields: Result<[IDFields<Model>]> = await fetch(where: predicate)
		return await fields.map { $0.map(\.id) }
	}
}
