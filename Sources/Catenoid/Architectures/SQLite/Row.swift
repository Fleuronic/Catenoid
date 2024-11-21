// Copyright © Fleuronic LLC. All rights reserved.

import protocol Schemata.ModelProjection
import protocol Catena.Representable

public protocol Row: Representable, Fields {
	init(from representable: some Representable<Value, IdentifiedValue>)
}
