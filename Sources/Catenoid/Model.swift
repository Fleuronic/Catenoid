// Copyright © Fleuronic LLC. All rights reserved.

public import struct PersistDB.ValueSet
public import protocol PersistDB.Model
public import protocol Identity.Identifiable

public import protocol Schemata.ModelValue

public protocol Model: Sendable where IdentifiedModel.RawIdentifier: Sendable {
	associatedtype ID
	associatedtype IdentifiedModel: PersistDB.Model, Identifiable, Sendable

	var id: ID { get }
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
