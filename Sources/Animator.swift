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
	var duration: TimeInterval { get }

	///
	func animate()

	///
	func transition(completed: Bool)
}

extension Animator {

	/// This is a `no-op` implementation.
	public func transition(completed: Bool) { /* no-op */ }
}
