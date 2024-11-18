// Copyright © Fleuronic LLC. All rights reserved.

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
