// Copyright © Fleuronic LLC. All rights reserved.

import struct Identity.Identifier
import struct Catena.IDFields
import struct Schemata.Projection
import struct Foundation.UUID
import protocol Catena.Identifying
import protocol Identity.Identifiable
import protocol Schemata.ModelProjection
import protocol PersistDB.Model
import protocol PersistDB.ModelProjection

public extension Identifiable {
	typealias InvalidID = InvalidIdentifier<Self>
	typealias UngenerableID = UngenerableIdentifier<Self>
}

// MARK: -
extension IDFields: Fields where Model: PersistDB.Model {
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}

// MARK: -
extension IDFields: Schemata.ModelProjection, PersistDB.ModelProjection where Model: PersistDB.Model {
	public static var projection: Schemata.Projection<Model, Self> {
		.init(
			Self.init,
			Model.idKeyPath
		)
	}
}

// MARK: -

// MARK: -
public enum InvalidIdentifier<Model: Identifiable>: Identifying {}

// MARK: -
public enum UngenerableIdentifier<Model: Identifiable>: Identifying {}

// MARK: -
public extension Identifier where Value.RawIdentifier == UUID {
	static var random: Self { .init(rawValue: .init()) }
}
