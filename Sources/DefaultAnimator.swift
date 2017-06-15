//
//  DefaultAnimator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
public final class DefaultAnimator : Animator {

	///
	public enum Direction {
		case left, right, up, down
	}

	//
	///
	fileprivate private(set) lazy var context: Transition.Context = self.transition.context

	///
	fileprivate var optionalAnimation: ((Transition.Context) -> Void)? {
		return self.transition.animation
	}

	///
	fileprivate var optionalCompletion: ((Transition.Context) -> Void)? {
		return self.transition.completion
	}

	///
	fileprivate private(set) lazy var containerView: UIView = self.context.containerView

	///
	fileprivate private(set) lazy var fromView: UIView = self.context.view(forKey: .from)

	///
	fileprivate private(set) lazy var toView: UIView = self.context.view(forKey: .to)

	///
	fileprivate private(set) lazy var shouldPush: Bool = self.context.kind == .push

	///
	fileprivate var views: [UIView] {
		return self.shouldPush ? [self.fromView, self.toView] : [self.toView, self.fromView]
	}

	///
	fileprivate let factor = CGFloat(0.3)

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
}

extension DefaultAnimator {

	///
	private func signValue(for direction: Direction) -> CGFloat {
		return direction == .left || direction == .up ? 1 : -1
	}

	///
	private func preTransitionState() {

		self.views.forEach {
			$0.autoresizingMask = .complete
			$0.translatesAutoresizingMaskIntoConstraints = true
			$0.removeFromSuperview()
			$0.frame = self.containerView.bounds
			self.containerView.addSubview($0)
		}

		let size = self.containerView.bounds.size

		switch self.direction {
		case .left, .right:
			let translation = signValue(for: self.direction) * (size.width * (self.shouldPush ? 1 : self.factor))
			self.toView.transform = CGAffineTransform(translationX: translation, y: 0)
		case .up, .down:
			let translation = signValue(for: self.direction) * size.height
			self.toView.transform = CGAffineTransform(translationX: 0, y: translation)
		}
		self.fromView.transform = .identity
	}

	///
	private func finalState() {

		let size = self.containerView.bounds.size

		switch self.direction {
		case .left, .right:
			let translation = signValue(for: self.direction) * (size.width * (self.shouldPush ? self.factor : 1))
			self.fromView.transform = CGAffineTransform(translationX: -(translation), y: 0)
		case .up, .down:
			self.fromView.transform = .identity
		}
		self.toView.transform = .identity

		self.optionalAnimation?(self.context)
	}

	///
	private func complete(_ didComplete: Bool) {
		self.fromView.transform = .identity
		self.fromView.removeFromSuperview()
		self.optionalCompletion?(self.context)
		self.transition.complete(didComplete)
	}

	///
	public func animate() {

		self.preTransitionState()

		if context.isAnimated {
			UIView.animate(withDuration: 0.3,
			               delay: 0,
			               options: .curveEaseIn,
			               animations: self.finalState,
			               completion: self.complete)
		} else {
			self.finalState()
			self.complete(true)
		}
	}
}
