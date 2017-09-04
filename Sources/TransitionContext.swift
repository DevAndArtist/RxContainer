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
		
		//==========-----------------------------==========//
		//=====----- Private/Internal properties -----=====//
		//==========-----------------------------==========//

		///
		private let fromViewController: UIViewController
		
		///
		private let toViewController: UIViewController
		
		//==========------------------------==========//
		//=====----- Open/Public properties -----=====//
		//==========------------------------==========//

		///
		public let kind: Kind

		///
		public let containerView: UIView

		///
		public let isAnimated: Bool

		///
		public let isInteractive: Bool
		
		//==========-------------==========//
		//=====----- Initializer -----=====//
		//==========-------------==========//

		///
		init(kind: Kind,
		     containerView: UIView,
		     fromViewController: UIViewController,
		     toViewController: UIViewController,
		     option: ContainerViewController.Option) {
			// Initialize all properties neede for the transition
			self.kind = kind
			self.containerView = containerView
			self.fromViewController = fromViewController
			self.toViewController = toViewController
			self.isAnimated = option.isAnimated
			self.isInteractive = option.isInteractive
		}
	}
}

extension Transition.Context {
	///
	public func viewController(forKey key: Key) -> UIViewController {
		switch key {
		case .from:
			return fromViewController
		case .to:
			return toViewController
		}
	}
	
	///
	public func view(forKey key: Key) -> UIView {
		return viewController(forKey: key).view
	}
}

extension Transition.Context {
	///
	public enum Key { case from, to }
	
	///
	public enum Kind { case push, pop }
}
