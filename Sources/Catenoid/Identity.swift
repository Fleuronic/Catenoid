// Copyright © Fleuronic LLC. All rights reserved.

import struct Identity.Identifier
import struct Foundation.UUID
import protocol Catena.Identifying
import protocol Identity.Identifiable

public extension Identifiable {
	typealias InvalidID = InvalidIdentifier<Self>
	typealias UngenerableID = UngenerableIdentifier<Self>
}

// MARK: -
public enum InvalidIdentifier<Model: Identifiable>: Identifying {}

// MARK: -
public enum UngenerableIdentifier<Model: Identifiable>: Identifying {}

// MARK: -
public extension Identifier where Value.RawIdentifier == UUID {
	static var random: Self { .init(rawValue: .init()) }
}
