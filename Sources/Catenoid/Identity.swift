// Copyright © Fleuronic LLC. All rights reserved.

import Identity
import Schemata
import PersistDB
import Foundation
import struct Catena.IDFields
import protocol Catena.Identifying
import protocol Catena.StringEncodable

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

extension Identifier: Schemata.AnyModelValue where Value.RawIdentifier: ModelValue & StringEncodable {
	public static var anyValue: AnyValue {
		.init(
			String.value.bimap(
				decode: { Self(rawValue: Value.RawIdentifier.encode(with: $0)) },
				encode: \.description
			)
		)
	}
}

// MARK: -
extension Identifier: Schemata.ModelValue where Value.RawIdentifier: ModelValue & StringEncodable {
	public static var value: Schemata.Value<Value.RawIdentifier.Encoded, Self> {
		Value.RawIdentifier.value.bimap(
			decode: Self.init(rawValue:),
			encode: \.rawValue
		)
	}
}

// MARK: -
public extension Identifier where Value.RawIdentifier == UUID {
	static var random: Self { .init(rawValue: .init()) }
}

// MARK: -
public enum EmptyIdentifier<Identified: Identifiable>: Identifying {}

// MARK: -
public enum EmptyIdentifiers<Identified: Identifiable>: Identifying {}
