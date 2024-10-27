// Copyright © Fleuronic LLC. All rights reserved.

import struct Catena.IDFields
import struct Schemata.Projection
import protocol Schemata.ModelProjection
import protocol PersistDB.ModelProjection
import protocol PersistDB.Model

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
