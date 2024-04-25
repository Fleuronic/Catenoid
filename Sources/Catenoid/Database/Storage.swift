// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Catenary.IDFields
import protocol Catenary.Model
import protocol Catenary.Fields
import protocol Schemata.Model

public protocol Storage {
	associatedtype StorageError: Error

	func insert<Model: Catenary.Model>(_ model: Model) async -> Result<Model.ID, StorageError>
	func insert<Model: Catenary.Model>(_ models: [Model]) async -> Result<[Model.ID], StorageError>
	func fetch<Model: Catenary.Model, Fields: Catenary.Fields>(_ fields: Fields.Type, where: Predicate<Fields.Model>?) async -> Result<[Fields], StorageError> where Model == Fields.Model
	func update<Model: Catenary.Model>(_ valueSet: ValueSet<Model>, with id: Model.ID) async -> Result<Model.ID?, StorageError>
	func update<Model: Catenary.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>?) async -> Result<[Model.ID], StorageError>
	func delete<Model: Catenary.Model>(_ type: Model.Type, with id: Model.ID) async -> Result<Model.ID?, StorageError>
	func delete<Model: Catenary.Model>(_ type: Model.Type, with ids: [Model.ID]) async -> Result<[Model.ID], StorageError>
	func delete<Model: Catenary.Model>(_ type: Model.Type, where predicate: Predicate<Model>?) async -> Result<[Model.ID], StorageError>
}

// MARK: -
public extension Storage {
	func fetch<Model: Catenary.Model>(where predicate: Predicate<Model>? = nil) async -> Result<[Model.ID], StorageError> {
		await fetch(IDFields<Model>.self, where: predicate).map { $0.map(\.id) }
	}

	func fetch<Model: Catenary.Model, Fields: Catenary.Fields>(_ fields: Fields.Type, with id: Model.ID) async -> Result<Fields?, StorageError> where Model == Fields.Model {
		await fetch(fields, where: Model.idKeyPath == id).map(\.first)
	}

	// MARK: Storage
	func update<Model: Catenary.Model>(_ valueSet: ValueSet<Model>, with id: Model.ID) async -> Result<Model.ID?, StorageError> {
		await update(valueSet, where: Model.idKeyPath == id).map(\.first)
	}

	func delete<Model: Catenary.Model>(_ type: Model.Type, with id: Model.ID) async -> Result<Model.ID?, StorageError> {
		await delete(type, where: Model.idKeyPath == id).map(\.first)
	}

	func delete<Model: Catenary.Model>(_ type: Model.Type, with ids: [Model.ID]) async -> Result<[Model.ID], StorageError> {
		await delete(type, where: ids.contains(\.id))
	}
}