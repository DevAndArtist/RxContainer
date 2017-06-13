//
//  TransitionOperation.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
final class TransitionOperation : Operation {

	///
	let animator: Animator

	///
	private var _isExecuting = false

	///
	private var _isFinished = false

	///
	override var isAsynchronous: Bool {
		return false
	}

	///
	override var isExecuting: Bool {
		get { return _isExecuting }
		set {
			let key = "isExecuting"
			self.willChangeValue(forKey: key)
			self._isExecuting = newValue
			self.didChangeValue(forKey: key)
		}
	}

	///
	override var isFinished: Bool {
		get { return _isFinished }
		set {
			let key = "isFinished"
			self.willChangeValue(forKey: key)
			self._isFinished = newValue
			self.didChangeValue(forKey: key)
		}
	}

	///
	init(for animator: Animator) {
		self.animator = animator
	}

	///
	override func start() {
		self.isExecuting = true
		// The operation will only terminate if the animator called 
		// `transition.complete(_:)` correctly, which will trigger
		// the `transitionCompletion` block that contains 
		// `operation.isFinished = true`
		self.animator.animate()
	}
}
