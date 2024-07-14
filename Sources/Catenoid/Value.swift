// Copyright © Fleuronic LLC. All rights reserved.

import struct ReactiveSwift.SignalProducer
import protocol ReactiveSwift.Disposable

public extension Result where Failure == Never {
	var value: Success {
		switch self {
		case let .success(value):
			return value
		}
	}
}

// MARK: -
public extension AsyncStream {
	var value: Element? {
		get async {
			await first { _ in true }
		}
	}
}

// MARK: -
public extension AsyncThrowingStream {
	var value: Element? {
		get async throws {
			try await first { _ in true }
		}
	}
}

// MARK: -
public extension SignalProducer where Error == Never {
	var value: Value? {
		get async {
			await asyncStream.value
		}
	}
}

public extension SignalProducer where Value == Never, Error == Never {
	func complete() async {
		var disposable: Disposable?

		await withCheckedContinuation { continuation in
			disposable = start { event in
				switch event {
				case .completed:
					continuation.resume()
				case .interrupted:
					disposable?.dispose()
				}
			}
		}
	}
}
