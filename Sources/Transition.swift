//
//  Transition.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {

	public struct Transition : ViewComponent {

		public enum Kind { case push, pop }

		// internal properties
		let viewComponents: [ViewComponentKey: UIViewController]

		// public properties
		public let kind: Kind
		public let containerViewController: ContainerViewController
		public let isAnimated: Bool

		init(viewComponents: [ViewComponentKey: UIViewController],
		     kind: Kind,
		     containerViewController: ContainerViewController,
		     isAnimated: Bool) {
			//
			self.viewComponents = viewComponents
			self.kind = kind
			self.containerViewController = containerViewController
			self.isAnimated = isAnimated
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
