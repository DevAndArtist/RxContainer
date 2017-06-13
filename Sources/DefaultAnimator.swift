//
//  DefaultAnimator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

public final class DefaultAnimator : Animator {

	public enum Direction {
		case left, right, top, bottom
	}

	public let transition: Transition
	public let direction: Direction
	public var duration: TimeInterval { return 0.3 }

	public init(for transition: Transition,
	            withDirection direction: Direction) {
		self.transition = transition
		self.direction = direction
	}

	public func animate() {

		let context = self.transition.context
		let optionalAnimation = self.transition.animation

		func finalState() {

			if context.isAnimated {
				optionalAnimation?(context)
			} else {
				UIView.performWithoutAnimation { optionalAnimation?(context) }
			}
		}

		func complete(_ didComplete: Bool) {
			self.transition.complete(didComplete)
			self.transition.completion?(context)
		}

		if context.isAnimated {
			UIView.animate(withDuration: self.duration, animations: finalState, completion: complete)
		} else {
			finalState()
			complete(true)
		}
	}
}
