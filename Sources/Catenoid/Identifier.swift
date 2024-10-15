// Copyright © Fleuronic LLC. All rights reserved.

public import struct Identity.Identifier
public import struct Schemata.Value
public import struct Schemata.AnyValue
public import struct Foundation.UUID
public import protocol Schemata.ModelValue
public import protocol Schemata.AnyModelValue

public extension Identifier where Value.RawIdentifier == UUID {
	static var random: Self { .init(rawValue: .init()) }
}

// MARK: -
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
public protocol StringEncodable: CustomStringConvertible {
	static func encode(with string: String) -> Self
}

// MARK: -
extension Int: StringEncodable {
	public static func encode(with string: String) -> Self { .init(string)! }
}

// MARK: -
extension String: StringEncodable {
	public static func encode(with string: String) -> Self { string }
}

// MARK: -
extension UUID: StringEncodable {
	public static func encode(with string: String) -> Self { .init(uuidString: string)! }
}

