// Copyright © Fleuronic LLC. All rights reserved.

import protocol Schemata.ModelProjection
import protocol Catena.Representable

public protocol Row: Representable, Fields {}

// MARK: -
public protocol RowIdentifying where IdentifyingRow.Model: Representable {
	associatedtype IdentifyingRow: Row

	static func identified(from row: IdentifyingRow?) -> IdentifyingRow.Model?
}
