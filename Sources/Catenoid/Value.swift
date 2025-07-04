// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

public extension Result where Success == Never {
	@available(*, unavailable)
	var value: Never {
		fatalError()
	}
}

public extension Result where Failure == Never {
	var value: Success {
		switch self {
		case let .success(value): value
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
		await withCheckedContinuation { continuation in
			start { event in
				switch event {
				case .completed:
					continuation.resume()
				default:
					break
				}
			}
		}
	}
}
