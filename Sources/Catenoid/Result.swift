// Copyright © Fleuronic LLC. All rights reserved.

public protocol ResultProviding {
	typealias Results<Resource> = Result<[Resource], Never>
	typealias SingleResult<Resource> = Result<Resource, Never>
	typealias NoResults = Result<Void, Never>
}
