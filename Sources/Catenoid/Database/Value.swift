// Copyright © Fleuronic LLC. All rights reserved.

import ReactiveSwift

public extension SignalProducer where Error == Never {
	var value: Value {
		get async {
			await asyncStream.first { _ in true }!
		}
	}
}
