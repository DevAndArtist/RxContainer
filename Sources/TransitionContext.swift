//
//  TransitionContext.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension Transition {

	///
	public struct Context {

		///
		public enum Key { case from, to }

		///
		public enum Kind { case push, pop }

		// internal properties
		///
		let fromViewController: UIViewController
		
		///
		let toViewController: UIViewController

		// public properties
		///
		public let kind: Kind

		///
		public let containerView: UIView

		///
		public let isAnimated: Bool

		///
		public let isInteractive: Bool

		///
		init(kind: Kind,
		     containerView: UIView,
		     fromViewController: UIViewController,
		     toViewController: UIViewController,
		     isAnimated: Bool,
		     isInteractive: Bool) {
			// Initialize all properties neede for the transition
			self.kind = kind
			self.containerView = containerView
			self.fromViewController = fromViewController
			self.toViewController = toViewController
			self.isAnimated = isAnimated
			self.isInteractive = isInteractive
		}

		///
		public func viewController(forKey key: Key) -> UIViewController {
			switch key {
			case .from:
				return self.fromViewController
			case .to:
				return self.toViewController
			}
		}

		///
		public func view(forKey key: Key) -> UIView {
			return self.viewController(forKey: key).view
		}
	}
}
