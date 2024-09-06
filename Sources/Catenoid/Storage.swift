// Copyright © Fleuronic LLC. All rights reserved.

import struct PersistDB.Predicate
import protocol PersistDB.Model
import protocol Catena.Fields
import protocol Schemata.ModelProjection
import protocol Identity.Identifiable

public protocol Storage: Sendable {
	associatedtype StorageError: Error

	func insert<Model: Catenoid.Model>(_ model: Model) async -> Result<Model.ID, StorageError> where Model.ID == Model.IdentifiedModel.ID
	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>?) async -> Result<[Fields], StorageError>
	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type, with ids: [Model.ID]?) async -> Result<[Model.ID], StorageError>
}

public extension Storage {
	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Result<[Model.ID], StorageError> where Model.ID == Model.IdentifiedModel.ID, StorageError == Never {
		await .success(models.concurrentMap { await insert($0) }.map(\.value))
	}
}
