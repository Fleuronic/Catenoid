// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

public extension Result where Failure == Never {
	var value: Success {
		switch self {
		case let .success(value):
			return value
		}
	}
}

// MARK: -
public extension SignalProducer where Error == Never {
	var value: Value {
		get async {
			await asyncStream.first { _ in true }!
		}
	}
}
