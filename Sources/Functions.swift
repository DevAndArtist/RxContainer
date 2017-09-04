//
//  Functions.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 24.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

/// Convenient prefix operator to negate a whole closure that returns a boolean value.
prefix func ! <T>(closure: @escaping (T) -> Bool) -> (T) -> Bool {
	return { !closure($0) }
}

/// Default function for any transition.
public func animator(for transition: Transition) -> Animator {
	//
	let direction: DefaultAnimator.Direction = transition.context.kind == .push ? .left : .right
	// Get an animator for the transition
	return transition
		.containerViewController
		.delegate?
		.animator(for: transition) ?? DefaultAnimator(for: transition, withDirection: direction)
}
