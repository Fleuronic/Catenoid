// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import Identity

public protocol Model: Sendable where IdentifiedModel.RawIdentifier: Sendable {
	associatedtype ID
	associatedtype IdentifiedModel: PersistDB.Model, Identifiable, Sendable

	var identifiedModelID: ID? { get }
	var valueSet: ValueSet<IdentifiedModel> { get }

	static var queryName: String { get }
}

// MARK: -
public extension Model {
	// MARK: Model
	static var queryName: String {
		.init(IdentifiedModel.schema.name.dropLast())
	}
}
