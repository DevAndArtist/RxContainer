//
//  DefaultAnimator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

public final class DefaultAnimator : Animator {

	///
	public enum Direction {
		case left, right, top, bottom
	}

	//
	var context: Transition.Context {
		return self.transition.context
	}

	var optionalAnimation: ((Transition.Context) -> Void)? {
		return self.transition.animation
	}

	var optionalCompletion: ((Transition.Context) -> Void)? {
		return self.transition.completion
	}

	var containerView: UIView {
		return self.context.containerView
	}

	var fromView: UIView {
		return self.context.view(forKey: .from)
	}

	var toView: UIView {
		return self.context.view(forKey: .to)
	}

	var shouldPush: Bool {
		return self.context.kind == .push
	}

	var views: [UIView] {
		return self.shouldPush ? [self.fromView, self.toView] : [self.toView, self.fromView]
	}

	//
	///
	public let transition: Transition

	///
	public let direction: Direction

	///
	public init(for transition: Transition,
	            withDirection direction: Direction) {
		self.transition = transition
		self.direction = direction
	}

	func finalState() {

		if self.context.isAnimated {
			self.optionalAnimation?(self.context)
		} else {
			UIView.performWithoutAnimation { self.optionalAnimation?(self.context) }
		}
	}

	///
	public func animate() {

		self.views.forEach {
			$0.autoresizingMask = .complete
			$0.translatesAutoresizingMaskIntoConstraints = true
			$0.removeFromSuperview()
			$0.frame = self.containerView.bounds
			self.containerView.addSubview($0)
		}

		func complete(_ didComplete: Bool) {
			self.transition.complete(didComplete)
			self.optionalCompletion?(self.context)
		}

		if context.isAnimated {
			UIView.animate(withDuration: 0.3, animations: self.finalState, completion: complete)
		} else {
			finalState()
			complete(true)
		}
	}
}
