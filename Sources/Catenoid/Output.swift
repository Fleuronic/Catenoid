@preconcurrency import ReactiveSwift
import protocol Catena.Output

extension SignalProducer: Catena.Output, @unchecked Swift.Sendable {
	public typealias Success = Value
	public typealias Failure = Error
}

// MARK: -
extension SignalProducer where Value: Sendable {
	public var results: AsyncStream<Result<Value, Error>> {
		.init { continuation in
			let disposable = start { event in
				switch event {
				case let .value(value):
					continuation.yield(.success(value))
				case .completed, .interrupted:
					continuation.finish()
				case let .failed(error):
					continuation.yield(.failure(error))
				}
			}

			continuation.onTermination = { _ in
				disposable.dispose()
			}
		}
	}
}
