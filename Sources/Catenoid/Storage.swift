// Copyright © Fleuronic LLC. All rights reserved.

import struct PersistDB.Predicate
import protocol Catena.Fields

public protocol Storage {
	associatedtype StorageError: Error

	func insert<Model: Catenoid.Model>(_ model: Model) async -> Result<Model.ID, StorageError> where Model.ID == Model.IdentifiedModel.ID
	func fetch<Fields: Catenoid.Fields>(where predicate: Predicate<Fields.Model>?) async -> Result<[Fields], StorageError>
	func delete<Model: Catenoid.Model>(_ type: Model.Type, where predicate: Predicate<Model.IdentifiedModel>?) async -> Result<[Model.ID], StorageError>  where Model.ID == Model.IdentifiedModel.ID
}

public extension Storage {
	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Result<[Model.ID], StorageError> where Model.ID == Model.IdentifiedModel.ID, StorageError == Never {
		await .success(models.concurrentMap(insert).map(\.value))
	}

	func delete<Model: Catenoid.Model>(_ type: Model.Type, with ids: [Model.ID]) async -> Result<[Model.ID], StorageError> where Model.ID == Model.IdentifiedModel.ID, StorageError == Never {
		await delete(type, where: ids.contains(Model.IdentifiedModel.idKeyPath))
	}
}
