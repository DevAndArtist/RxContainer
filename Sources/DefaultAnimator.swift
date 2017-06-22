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

	///
	public enum Style {
		case overlap, slide
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
		view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
		view.isUserInteractionEnabled = false
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
	fileprivate var shouldPop: Bool { return !self.shouldPush }

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

	///
	fileprivate let propertyAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)

	///
	fileprivate var progressWhenInterrupted = CGFloat(0)

	//
	///
	public let transition: Transition

	///
	public let direction: Direction

	///
	public let style: Style

	///
	public init(for transition: Transition,
	            withDirection direction: Direction,
	            style: Style = .overlap) {
		self.transition = transition
		self.direction = direction
		self.style = style
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
		let shouldOverlap = self.style == .overlap
		//
		let constraint: NSLayoutConstraint
		switch self.direction {
		case .left, .right:
			let (anchorForPop, centerXAnchor): (NSLayoutXAxisAnchor, NSLayoutXAxisAnchor)
			if self.direction.isLeftOrUp {
				anchorForPop = shouldOverlap ? self.containerView.trailingAnchor : self.layoutGuide.trailingAnchor
				centerXAnchor = self.shouldPush ? self.layoutGuide.trailingAnchor : anchorForPop
			} else {
				anchorForPop = shouldOverlap ? self.containerView.leadingAnchor : self.layoutGuide.leadingAnchor
				centerXAnchor = self.shouldPush ? self.layoutGuide.leadingAnchor : anchorForPop
			}
			constraint = self.toView.centerXAnchor.constraint(equalTo: centerXAnchor)
		case .up, .down:
			let (anchorForPop, centerYAnchor): (NSLayoutYAxisAnchor, NSLayoutYAxisAnchor)
			if self.direction.isLeftOrUp {
				anchorForPop = shouldOverlap ? self.containerView.centerYAnchor : self.layoutGuide.bottomAnchor
				centerYAnchor = self.shouldPush ? self.layoutGuide.bottomAnchor : anchorForPop
			} else {
				anchorForPop = shouldOverlap ? self.containerView.centerYAnchor : self.layoutGuide.topAnchor
				centerYAnchor = self.shouldPush ? self.layoutGuide.topAnchor : anchorForPop
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
		let shouldOverlap = self.style == .overlap
		//
		let constraint: NSLayoutConstraint
		switch self.direction {
		case .left, .right:
			let (anchorForPush, centerXAnchor): (NSLayoutXAxisAnchor, NSLayoutXAxisAnchor)
			if self.direction.isLeftOrUp {
				anchorForPush = shouldOverlap ? self.containerView.leadingAnchor : self.layoutGuide.leadingAnchor
				centerXAnchor = self.shouldPush ? anchorForPush : self.layoutGuide.leadingAnchor
			} else {
				anchorForPush = shouldOverlap ? self.containerView.trailingAnchor : self.layoutGuide.trailingAnchor
				centerXAnchor = self.shouldPush ? anchorForPush : self.layoutGuide.trailingAnchor
			}
			constraint = self.fromView.centerXAnchor.constraint(equalTo: centerXAnchor)
		case .up, .down:
			let (anchorForPush, centerYAnchor): (NSLayoutYAxisAnchor, NSLayoutYAxisAnchor)
			if self.direction.isLeftOrUp {
				anchorForPush = shouldOverlap ? self.containerView.centerYAnchor : self.layoutGuide.topAnchor
				centerYAnchor = self.shouldPush ? anchorForPush : self.layoutGuide.topAnchor
			} else {
				anchorForPush = shouldOverlap ? self.containerView.centerYAnchor : self.layoutGuide.bottomAnchor
				centerYAnchor = self.shouldPush ? anchorForPush : self.layoutGuide.bottomAnchor
			}
			constraint = self.fromView.centerYAnchor.constraint(equalTo: centerYAnchor)
		}
		constraint.isActive = true
		//
		if let constraintToDeactivate = self.constraintToDeactivate {
			NSLayoutConstraint.deactivate([constraintToDeactivate])
		}
		//
		if self.shouldPop {
			self.toView.isUserInteractionEnabled = false
		}

		return {
			self.containerView.layoutIfNeeded()
			self.overlayView.alpha = self.shouldPush ? 1 : 0
			self.optionalAnimation?(self.context)
		}
	}

	///
	private func completeTransition(at position: UIViewAnimatingPosition) {
		UIView.performWithoutAnimation {
			self.constraintToDeactivate = nil
			self.overlayView.removeFromSuperview()
			self.containerView.removeLayoutGuide(self.layoutGuide)
			//
			self.toView.isUserInteractionEnabled = true
			self.fromView.isUserInteractionEnabled = true
			//
			let containerViewController = self.transition.containerViewController
			let action: (UIPanGestureRecognizer) -> Void = { [weak containerViewController] in
				if $0.state == .began { containerViewController?.pop(option: .interactive) }
			}
			//
			switch position {
			case .start:
				if self.shouldPop {
					self.gestureInView(forKey: .from)?.action = action
				}
				self.toView.removeFromSuperview()
				self.transition.complete(at: .start)
			case .end:
				if self.shouldPush && self.context.isInteractive {
					self.toView.addGestureRecognizer(PanGestureRecognizer(with: action))
				} else if self.shouldPop, let gesture = self.gestureInView(forKey: .from) {
					self.fromView.removeGestureRecognizer(gesture)
				}
				self.fromView.removeFromSuperview()
				self.optionalCompletion?(self.context)
				self.transition.complete(at: .end)
			case .current:
				fatalError("Transition should not stop somewhere in between")
			}
		}
	}

	///
	private func gestureInView(forKey key: Transition.Context.Key) -> PanGestureRecognizer? {
		return self.context.view(forKey: key)
		                   .gestureRecognizers?
		                   .flatMap { $0 as? PanGestureRecognizer }
		                   .first
	}

	///
	public func animate() {
		//
		UIView.performWithoutAnimation(self.preTransitionState)
		//
		let animation = self.postTransitionState()
		//
		if self.context.isAnimated {
			self.propertyAnimator.addAnimations(animation)
			self.propertyAnimator.addCompletion(self.completeTransition)
			self.propertyAnimator.startAnimation()
			//
			guard self.shouldPop && self.context.isInteractive else { return }
			//
			self.propertyAnimator.pauseAnimation()
			guard let gesture = self.gestureInView(forKey: .from) else {
				return self.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			}
			//
			gesture.action = { [weak self] in
				guard let animator = self else { return }
				let signValue: CGFloat = animator.direction.isLeftOrUp ? -1 : 1
				let isDirectionHorizontal = animator.direction == .left || animator.direction == .right
				switch $0.state {
				case .began:
					animator.propertyAnimator.pauseAnimation()
					animator.progressWhenInterrupted = animator.propertyAnimator.fractionComplete
				case .changed:
					let point = $0.translation(in: animator.containerView)
					let frame = animator.containerView.frame
					let size = isDirectionHorizontal ? frame.width : frame.height
					let translation = signValue * (isDirectionHorizontal ? point.x : point.y)
					let progress = translation / size + animator.progressWhenInterrupted
					animator.propertyAnimator.fractionComplete = progress
				default:
					let point = $0.velocity(in: animator.containerView)
					let velocity = signValue * (isDirectionHorizontal ? point.x : point.y)
					let progress = animator.propertyAnimator.fractionComplete
					let shouldReverse = progress < 0.5 && velocity < 100 || velocity < -100
					animator.propertyAnimator.isReversed = shouldReverse
					animator.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
				}
			}
		} else {
			UIView.performWithoutAnimation(animation)
			self.completeTransition(at: .end)
		}
	}
}
