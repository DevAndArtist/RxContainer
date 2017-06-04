//
//  Animator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

/// WARNING: Do not use this protocol directly, instead use `ContainerViewController.Animator`!
///
///   - Once protocol nesting is supported this protocol will be nested as `Animator` inside
///     `ContainerViewController`.
///   - Once `open/public protocol` inconsistency is resolved this protocol will become `open`.
///
/* open */ public protocol _Animator {

	func transitionDuration(using context: ContainerViewController.Transition.Context) -> TimeInterval
	func animateTransition(using context: ContainerViewController.Transition.Context)
	func animationEnded(_ transitionCompleted: Bool)
}

extension ContainerViewController {

	public typealias Animator = _Animator
}
