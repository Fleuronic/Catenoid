// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catena.Fields
import protocol Schemata.Model
import protocol PersistDB.ModelProjection

public protocol Fields<Model>: Catena.Fields, ModelProjection where Model == Self.Model {
	static func merge(lhs: Self, rhs: Self) -> Self
}

// MARK: -
public extension Fields {
	// MARK: Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	// MARK: Equatable
	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	// MARK: Fields
	static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}
