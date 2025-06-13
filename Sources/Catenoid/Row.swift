// Copyright © Fleuronic LLC. All rights reserved.

import protocol Schemata.ModelProjection
import protocol Catena.Representable
import protocol Identity.Identifiable

public protocol Row: Model, Representable {}

// MARK: -
public extension Row {
	static func merge(lhs: Self, rhs: Self) -> Self { lhs }

	// TODO: ValueSet with same format as Input
}
