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

		var isLeftOrUp: Bool {
			return self == .left || self == .up
		}
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
	fileprivate let layoutGuide = UILayoutGuide()

	///
	fileprivate let overlayView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		return view
	}()

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
		// Return in correct order depending on the kind of the transition context
		if self.shouldPush {
			return [self.fromView, self.overlayView, self.toView]
		}
		return [self.toView, self.overlayView, self.fromView]
	}

	///
	fileprivate let factor = CGFloat(0.3)

	///
	fileprivate var constraintToDeactivate: NSLayoutConstraint?

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
	private func setupLayoutGuide() {
		self.containerView.addLayoutGuide(self.layoutGuide)
		let constraints: [NSLayoutConstraint] = [
			self.layoutGuide.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 2),
			self.layoutGuide.heightAnchor.constraint(equalTo: self.containerView.heightAnchor, multiplier: 2),
			self.layoutGuide.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
			self.layoutGuide.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
		]
		NSLayoutConstraint.activate(constraints)
	}

	///
	private func setupViews() {
		//
		self.views.forEach {
			$0.removeFromSuperview()
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.containerView.addSubview($0)

			var constraints: [NSLayoutConstraint] = [
				$0.widthAnchor.constraint(equalTo: self.containerView.widthAnchor),
				$0.heightAnchor.constraint(equalTo: self.containerView.heightAnchor)
			]

			let lowerPriorityConstraints: [NSLayoutConstraint] = [
				$0.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
				$0.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
				$0.topAnchor.constraint(equalTo: self.containerView.topAnchor),
				$0.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
				$0.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
				$0.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
			]
			lowerPriorityConstraints.forEach {
				// Lower the priority of these constraints, so we don't have to remove them.
				// Other constraints with higher priorty will take over them when needed.
				$0.priority = UILayoutPriorityDefaultHigh
				constraints.append($0)
			}
			NSLayoutConstraint.activate(constraints)
		}
	}

	///
	private func preTransitionState() {
		//
		self.setupLayoutGuide()
		self.setupViews()
		//
		let constraint: NSLayoutConstraint
		switch self.direction {
		case .left, .right:
			let centerXAnchor: NSLayoutXAxisAnchor
			if self.direction.isLeftOrUp {
				centerXAnchor = self.shouldPush ? self.layoutGuide.trailingAnchor : self.containerView.trailingAnchor
			} else {
				centerXAnchor = self.shouldPush ? self.layoutGuide.leadingAnchor : self.containerView.leadingAnchor
			}
			constraint = self.toView.centerXAnchor.constraint(equalTo: centerXAnchor)
		case .up, .down:
			let centerYAnchor: NSLayoutYAxisAnchor
			if self.direction.isLeftOrUp {
				centerYAnchor = self.shouldPush ? self.layoutGuide.bottomAnchor : self.containerView.centerYAnchor
			} else {
				centerYAnchor = self.shouldPush ? self.layoutGuide.topAnchor : self.containerView.centerYAnchor
			}
			constraint = self.toView.centerYAnchor.constraint(equalTo: centerYAnchor)
		}
		constraint.isActive = true
		self.constraintToDeactivate = constraint
		//
		self.overlayView.alpha = self.shouldPush ? 0 : 1
		// Force update
		self.containerView.layoutIfNeeded()
	}

	///
	private func postTransitionState() -> () -> Void {
		//
		let constraint: NSLayoutConstraint
		switch self.direction {
		case .left, .right:
			let centerXAnchor: NSLayoutXAxisAnchor
			if self.direction.isLeftOrUp {
				centerXAnchor = self.shouldPush ? self.containerView.leadingAnchor : self.layoutGuide.leadingAnchor
			} else {
				centerXAnchor = self.shouldPush ? self.containerView.trailingAnchor : self.layoutGuide.trailingAnchor
			}
			constraint = self.fromView.centerXAnchor.constraint(equalTo: centerXAnchor)
		case .up, .down:
			let centerYAnchor: NSLayoutYAxisAnchor
			if self.direction.isLeftOrUp {
				centerYAnchor = self.shouldPush ? self.containerView.centerYAnchor : self.layoutGuide.topAnchor
			} else {
				centerYAnchor = self.shouldPush ? self.containerView.centerYAnchor : self.layoutGuide.bottomAnchor
			}
			constraint = self.fromView.centerYAnchor.constraint(equalTo: centerYAnchor)
		}
		constraint.isActive = true
		//
		if let constraintToDeactivate = self.constraintToDeactivate {
			NSLayoutConstraint.deactivate([constraintToDeactivate])
		}

		return {
			self.containerView.layoutIfNeeded()
			self.overlayView.alpha = self.shouldPush ? 1 : 0
			self.optionalAnimation?(self.context)
		}
	}

	///
	private func completeTransition(_ didComplete: Bool) {
		UIView.performWithoutAnimation {
			self.constraintToDeactivate = nil
			self.fromView.removeFromSuperview()
			self.overlayView.removeFromSuperview()
			self.containerView.removeLayoutGuide(self.layoutGuide)
			self.optionalCompletion?(self.context)
			self.transition.complete(at: .end)
		}
	}

	///
	public func animate() {
		//
		UIView.performWithoutAnimation(self.preTransitionState)
		//
		let animation = self.postTransitionState()
		//
		if context.isAnimated {
			UIView.animate(withDuration: 0.5,
			               delay: 0,
			               options: .curveEaseInOut,
			               animations: animation,
			               completion: self.completeTransition)
		} else {
			UIView.performWithoutAnimation(animation)
			self.completeTransition(true)
		}
	}
}
