// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catena.Fields
import struct Catena.IDFields
import protocol Catena.ResultProviding
import Identity
import struct Identity.Identifier
import PersistDB
import Schemata

public protocol Database<Store>: ResultProviding, Sendable where Error == Never {
	associatedtype Store

	var store: Store { get }

	static var types: [any AnyModel.Type] { get }

	mutating func clear() async throws
}

// MARK: -
public extension Database<Store<ReadWrite>> {
	static func createStore(named name: String) async throws -> Store {
		try await .open(with: name, for: types)
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
	@discardableResult
	func insert<Model: Catenoid.Model>(_ model: Model) async -> SingleResult<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		await .success(store.insert(.init(valueSet(for: model))).value!)
	}

	@discardableResult
	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Results<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		guard !models.isEmpty else { return .success([]) }

		var values: [Model.ID] = []
		for model in models {
			await values.append(store.insert(.init(valueSet(for: model))).value!)
		}

		return .success(values)
	}

	@discardableResult
	func update<Model: Catenoid.Model>(_ model: Model, with id: Model.ID) async -> SingleResult<Model.ID> where Model.ID == Model.IdentifiedModel.ID {
		let valueSet = model.valueSet.update(with: [Model.IdentifiedModel.idKeyPath == id])
		return await .success(store.insert(.init(valueSet)).value!)
	}

	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>? = nil) async -> Results<Fields> {
		await fetch(
			where: predicate,
			order: [],
			limit: nil,
			isUnordered: false
		)
	}

	/// - important: Skips the model's default ordering so a limited fetch can stop at the first match.
	func fetch<Fields: Catenoid.Fields>(
		where predicate: Predicate<Fields.Model>? = nil,
		limit: Int
	) async -> Results<Fields> {
		await fetch(
			where: predicate,
			order: [],
			limit: limit,
			isUnordered: true
		)
	}

	/// - important: `limit` caps ROWS, and a projection with array fields spans several rows per model,
	///              so a limited fetch of one can return a partially merged value.
	func fetch<Fields: Catenoid.Fields, Value>(
		where predicate: Predicate<Fields.Model>? = nil,
		sortedBy keyPath: KeyPath<Fields.Model, Value>,
		ascending: Bool = true,
		limit: Int? = nil
	) async -> Results<Fields> {
		await fetch(
			where: predicate,
			order: [.init(keyPath, ascending: ascending)],
			limit: limit,
			isUnordered: false
		)
	}

	func countDistinct<Model: PersistDB.Model, Value>(
		_ keyPath: KeyPath<Model, Value>,
		where predicate: Predicate<Model>? = nil
	) async -> SingleResult<Int> {
		let query = Query<None, Model>()
		let filtered = predicate.map(query.filter) ?? query

		return .success(await store.fetch(filtered.countDistinct(keyPath)).value ?? 0)
	}

	/// - important: Distinct rows are collapsed by the database, so the count reflects values, not models.
	func fetchAnonymous<Fields: Catenoid.AnonymousFields>(
		where predicate: Predicate<Fields.Model>? = nil,
		distinct: Bool = true
	) async -> Results<Fields> {
		var query = Query<None, Fields.Model>(
			predicates: predicate.map { [$0] } ?? [],
			order: [],
			groupedBy: .none,
			isUnordered: true
		)

		if distinct {
			query = query.distinct()
		}

		return .success(await store.fetch(anonymous: query).value ?? [])
	}

	func count<Model: PersistDB.Model>(
		_ type: Model.Type,
		where predicate: Predicate<Model>? = nil
	) async -> SingleResult<Int> {
		let query = Query<None, Model>()
		let filtered = predicate.map(query.filter) ?? query

		return .success(await store.fetch(filtered.count).value ?? 0)
	}

	/// - important: Distinct rows are collapsed by the database, so the count reflects values, not models.
	func fetchAnonymous<Fields: Catenoid.AnonymousFields, Value>(
		where predicate: Predicate<Fields.Model>? = nil,
		distinct: Bool = true,
		sortedBy keyPath: KeyPath<Fields.Model, Value>,
		ascending: Bool = true,
		limit: Int? = nil
	) async -> Results<Fields> {
		var query = Query<None, Fields.Model>(
			predicates: predicate.map { [$0] } ?? [],
			order: [.init(keyPath, ascending: ascending)],
			groupedBy: .none,
			limit: limit
		)

		if distinct {
			query = query.distinct()
		}

		return .success(await store.fetch(anonymous: query).value ?? [])
	}

	private func fetch<Fields: Catenoid.Fields>(
		where predicate: Predicate<Fields.Model>?,
		order: [Ordering<Fields.Model>],
		limit: Int?,
		isUnordered: Bool
	) async -> Results<Fields> {
		let query = Query(
			predicates: predicate.map { [$0] } ?? [],
			order: order,
			groupedBy: .init(.init(Fields.Model.idKeyPath)),
			limit: limit,
			isUnordered: isUnordered
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

	@discardableResult
	func delete<Model: PersistDB.Model & Identifiable>(where predicate: Predicate<Model>? = nil) async -> Results<Model.ID> where Model.RawIdentifier: Sendable {
		let fields: Results<IDFields<Model>> = await fetch(where: predicate)

		await store.delete(.init(predicate)).complete()
		return fields.map { $0.map(\.id) }
	}
}

// MARK: -
private extension Database<Store<ReadWrite>> {
	func valueSet<Model: Catenoid.Model>(for model: Model) -> ValueSet<Model.IdentifiedModel> where Model.ID == Model.IdentifiedModel.ID {
		let valueSet = model.valueSet
		guard let id = model.identifiedModelID else { return valueSet }
		return valueSet.update(with: [Model.IdentifiedModel.idKeyPath == id])
	}
}
