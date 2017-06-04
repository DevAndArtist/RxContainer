//
//  TransitionContext.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController.Transition {

	public struct Context : ViewComponent {

		// internal properties
		let viewComponents: [ViewComponentKey: UIViewController]

		// public properties
		public let containerView: UIView
		public let isAnimated: Bool

		init(viewComponents: [ViewComponentKey: UIViewController], containerView: UIView, isAnimated: Bool) {
			self.viewComponents = viewComponents
			self.containerView = containerView
			self.isAnimated = isAnimated
		}

		public func completeTransition(_ didComplete: Bool) {

		}

		public func viewController(forKey key: ViewComponentKey) -> UIViewController {
			guard let viewController = self.viewComponents[key] else {
				fatalError("Could not find any view controller for key: `\(key)`.")
			}
			return viewController
		}

		public func view(forKey key: ViewComponentKey) -> UIView {
			return self.viewController(forKey: key).view
		}
	}
}
