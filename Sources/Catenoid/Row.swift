// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import Identity
import protocol Catena.Representable

public protocol Row: Model, Representable {}

// MARK: -
public extension Row {
	static func merge(lhs: Self, rhs: Self) -> Self { lhs }
}
