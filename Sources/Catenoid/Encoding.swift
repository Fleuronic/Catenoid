// Copyright © Fleuronic LLC. All rights reserved.

import struct Identity.Identifier
import struct Schemata.Value
import struct Schemata.AnyValue
import protocol Schemata.ModelValue
import protocol Schemata.AnyModelValue
import struct Foundation.UUID

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

extension Identifier: Schemata.ModelValue where Value.RawIdentifier: ModelValue & StringEncodable {
	public static var value: Schemata.Value<Value.RawIdentifier.Encoded, Self> {
		Value.RawIdentifier.value.bimap(
			decode: Self.init(rawValue:),
			encode: \.rawValue
		)
	}
}
