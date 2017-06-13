//
//  Transition.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {

	public struct Transition {

		public enum Key { case from, to }
		public enum Kind { case push, pop }

		// internal properties
		let fromViewController: UIViewController
		let toViewController: UIViewController

		// public properties
		public let kind: Kind
		public let containerView: UIView
		public let isAnimated: Bool

		init(ofKind kind: Kind,
		     on containerView: UIView,
		     from fromViewController: UIViewController,
		     to toViewController: UIViewController,
		     animated: Bool) {
			// Initialize all properties neede for the transition
			self.kind = kind
			self.containerView = containerView
			self.fromViewController = fromViewController
			self.toViewController = toViewController
			self.isAnimated = animated
		}

		public func viewController(forKey key: Key) -> UIViewController {
			switch key {
			case .from:
				return self.fromViewController
			case .to:
				return self.toViewController
			}
		}

		public func view(forKey key: Key) -> UIView {
			return self.viewController(forKey: key).view
		}
	}
}
