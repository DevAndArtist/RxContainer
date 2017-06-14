//
//  Animator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

/// WARNING: Do not use this protocol directly, instead use `ContainerViewController.Animator`.
///   - Once protocol nesting is supported this protocol will be nested as `Animator` inside
///     `ContainerViewController`.
///   - Once `open/public protocol` inconsistency is resolved this protocol will become `open`.
/* open */ public protocol Animator : class {

	///
	var transition: Transition { get }

	///
	func animate()

	///
	func transition(completed: Bool)
}

extension Animator {

	/// This is a `no-op` implementation, re-implement this method
	/// if you need to perform work after the transition completed.
	public func transition(completed: Bool) { /* no-op */ }
}

extension Animator {

	func add(operation: TransitionOperation? = nil, completion: @escaping () -> Void) {
		self.transition.transitionCompletion = {
			[unowned self, weak operation] in
			// Finish transition work
			completion()
			// Notify the animator about completion
			self.transition(completed: $0)
			// Finish operation to notify the queue
			operation?.isFinished = true
		}
	}
}
