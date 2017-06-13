//
//  TransitionCoordinator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {

	public final class TransitionCoordinator {

		private(set) var animation: ((Transition) -> Void)?
		private(set) var completion: ((Transition) -> Void)?

		public let transition: Transition

		init(for transition: Transition) {
			self.transition = transition
		}

		public func animate(alongsideTransition animation: ( /* @escaping */ (Transition) -> Void)?,
		                    completion: ( /* @escaping */ (Transition) -> Void)? = nil) {
			self.animation = animation
			self.completion = completion
		}
	}
}
