// Copyright © Fleuronic LLC. All rights reserved.

public import struct Catena.IDFields
public import struct Schemata.Projection
public import protocol Schemata.ModelProjection
public import protocol PersistDB.ModelProjection
public import protocol PersistDB.Model

extension IDFields: Fields where Model: PersistDB.Model {
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}

extension IDFields: Schemata.ModelProjection, PersistDB.ModelProjection where Model: PersistDB.Model {
	public static var projection: Schemata.Projection<Model, Self> {
		.init(
			Self.init,
			Model.idKeyPath
		)
	}
}
