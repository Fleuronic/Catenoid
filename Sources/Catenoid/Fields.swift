// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catena.Fields
import protocol Schemata.Model
import protocol PersistDB.ModelProjection

public protocol Fields<Model>: Catena.Fields, ModelProjection where Model == Self.Model {
	static func merge(lhs: Self, rhs: Self) -> Self
}

// MARK: -
extension Fields {
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}
