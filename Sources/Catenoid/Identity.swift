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
	typealias InvalidID = EmptyIdentifier<Self>
	typealias UngenerableID = EmptyIdentifier<Self>
	typealias UngenerableIDs = EmptyIdentifiers<Self>
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
public extension Identifier where Value.RawIdentifier == UUID {
	static var random: Self { .init(rawValue: .init()) }
}

// MARK: -
public enum EmptyIdentifier<T: Identifiable>: Identifying {}

// MARK: -
public enum EmptyIdentifiers<T: Identifiable>: Identifying {}
