// Copyright © Fleuronic LLC. All rights reserved.

public import Schemata

public import protocol Catena.Fields
public import protocol PersistDB.ModelProjection

public protocol Fields<Model>: Catena.Fields, ModelProjection where Model == Self.Model {
	static func merge(lhs: Self, rhs: Self) -> Self
}

// MARK: -
public extension Fields {
	static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}
