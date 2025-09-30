// Copyright © Fleuronic LLC. All rights reserved.

import Identity
import Schemata
import PersistDB
import Foundation
import enum Catena.EmptyIdentifier
import enum Catena.EmptyIdentifiers
import struct Catena.IDFields
import protocol Catena.Identifying

public extension Identifiable {
	typealias UngenerableID = EmptyIdentifier<Self>
	typealias UngenerableIDs = EmptyIdentifiers<Self>
}

// MARK: -
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

// MARK: -
extension Identifier: Schemata.AnyModelValue {
	public static var anyValue: AnyValue {
		if Value.RawIdentifier.self == Int.self {
			.init(
				Int.value.bimap(
					decode: { Self(rawValue: $0 as! Value.RawIdentifier) },
					encode: { $0.rawValue as! Int }
				)
			)
		} else {
			.init(
				String.value.bimap(
					decode: { Self(rawValue: $0 as! Value.RawIdentifier) },
					encode: \.description
				)
			)
		}
	}
}

extension Identifier: Schemata.ModelValue where Value.RawIdentifier: ModelValue {
	public static var value: Schemata.Value<Value.RawIdentifier.Encoded, Self> {
		Value.RawIdentifier.value.bimap(
			decode: { Self(rawValue: $0) },
			encode: \.rawValue
		)
	}
}
