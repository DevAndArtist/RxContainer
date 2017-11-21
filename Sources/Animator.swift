//
//  Animator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
public protocol Animator : AnyObject {
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
	public /* default */ func transition(completed: Bool) { /* no-op */ }
}

extension Animator {
	///
	func add(operation: TransitionOperation? = nil, completion: @escaping () -> Void) {
		transition.transitionCompletion = { [unowned self, weak operation] in
			// Finish transition work
			($0 == .end).whenTrue(execute: completion)
			// Notify the animator about completion
			self.transition(completed: true)
			// Finish operation to notify the queue
			operation?.isFinished = true
		}
	}
}
