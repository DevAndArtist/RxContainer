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
	fileprivate let propertyAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut)

	///
	fileprivate var progressWhenInterrupted = CGFloat(0)

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
			if self.shouldPop {
				self.toView.isUserInteractionEnabled = true
			}
			//
			switch position {
			case .start:
				self.toView.removeFromSuperview()
				self.transition.complete(at: .start)
			case .end:
				if self.shouldPush {
					let toViewController = self.context.viewController(forKey: .to)
					let gesture = PanGestureRecognizer()
					self.toView.addGestureRecognizer(gesture)
					gesture.delaysTouchesBegan = true
					gesture.action = { [weak toViewController] in
						if $0.state == .began {
							(toViewController?.parent as? ContainerViewController)?.pop(option: .interactive)
						}
					}
				} else if let gesture = self.gestureInView(forKey: .from) {
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
			if self.shouldPop && self.context.isInteractive {
				self.propertyAnimator.pauseAnimation()
				guard let gesture = self.gestureInView(forKey: .from) else {
					return self.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
				}
				//
				gesture.action = { [weak self] in
					guard let animator = self else { return }
					switch $0.state {
					case .began:
						animator.propertyAnimator.pauseAnimation()
						animator.progressWhenInterrupted = animator.propertyAnimator.fractionComplete
					case .changed:
						let translation = $0.translation(in: animator.containerView)
						let width = animator.containerView.frame.width
						let progress = translation.x / width + animator.progressWhenInterrupted
						animator.propertyAnimator.fractionComplete = progress
					case .ended:
						animator.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
					default:
						break
					}
				}
			}
		} else {
			UIView.performWithoutAnimation(animation)
			self.completeTransition(at: .end)
		}
	}
}

final class PanGestureRecognizer : UIPanGestureRecognizer {

	var action: ( /* @escaping */ (UIPanGestureRecognizer) -> Void)?

	init() {
		super.init(target: nil, action: nil)
		self.maximumNumberOfTouches = 1
		self.addTarget(self, action: #selector(self.handlePan(_:)))
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		self.action?(gesture)
	}
}
