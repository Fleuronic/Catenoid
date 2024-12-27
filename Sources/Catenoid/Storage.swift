// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB

import struct Identity.Identifier
import protocol Identity.Identifiable
import protocol Schemata.ModelProjection
import protocol Catena.Fields

public protocol Storage: Sendable {
	associatedtype StorageError: Error

	func insert<Model: Catenoid.Model>(_ model: Model) async -> Result<Model, StorageError> where Model.ID == Model.IdentifiedModel.ID
	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>?) async -> Result<[Fields], StorageError>
	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type) async -> Result<[Model.ID], StorageError>
	func delete<Model: PersistDB.Model & Identifiable>(with ids: [Identifier<Model>]) async -> Result<[Model.ID], StorageError>
}

// MARK: -
public extension Storage {
	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Result<[Model], StorageError> where Model.ID == Model.IdentifiedModel.ID, StorageError == Never {
		await .success(models.map { await insert($0) }.map(\.value))
	}

	func fetch<Fields: Catenoid.Fields>(with id: Fields.Model.ID) async -> Result<[Fields], StorageError> {
		await fetch(where: Fields.Model.idKeyPath == id)
	}

	func fetch<Fields: Catenoid.Fields>(with ids: [Fields.Model.ID]) async -> Result<[Fields], StorageError> {
		await fetch(where: ids.contains(Fields.Model.idKeyPath))
	}

	func delete<Model: PersistDB.Model & Identifiable>(with id: Identifier<Model>) async -> Result<[Model.ID], StorageError> {
		await delete(with: [id])
	}
}
