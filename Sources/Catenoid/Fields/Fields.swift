// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catena.Fields
import protocol PersistDB.ModelProjection

public protocol Fields: Catena.Fields, ModelProjection {
	static func merge(lhs: Self, rhs: Self) -> Self
}
