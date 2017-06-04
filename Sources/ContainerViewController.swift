//
//  ContainerViewController.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import RxSwift
import UIKit

open class ContainerViewController : UIViewController {

	// internal properties
	let disposeBag = DisposeBag()
	let eventsSubject = PublishSubject<ContainerViewController.Event>()

	// open/public properties
	open var viewControllers: [UIViewController] = []

	open var rootViewController: UIViewController? {
		return self.viewControllers.first
	}

	open var topViewController: UIViewController? {
		return self.viewControllers.last
	}

	/// Once the syntax sugar from SE-0111 commentary
	/// (https://lists.swift.org/pipermail/swift-evolution-announce/2016-July/000233.html)
	/// made into the language, this closure will become either
	///    - `var animator(for:): (Transition) -> Animator?` or
	///    - `var animator: (for: Transition) -> Animator?`
	open var animator /* (for:) */: (Transition) -> Animator? = {
		_ in
		return nil
	}

	open var events: Observable<ContainerViewController.Event> {
		return self.eventsSubject.asObservable()
	}

	public init() {
		super.init(nibName: nil, bundle: nil)
	}

	public convenience init(_ viewControllers: UIViewController...) {
		self.init()
		self.viewControllers = viewControllers
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

extension ContainerViewController {

	open func push(_ viewController: UIViewController, animated: Bool = true) {

	}

	@discardableResult
	open func pop(animated: Bool = true) -> UIViewController? {
		return nil
	}

	@discardableResult
	open func pop(to viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
		return nil
	}

	@discardableResult
	open func popToRootViewController(animated: Bool = true) -> [UIViewController]? {
		return nil
	}

	open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = true) {

	}
}
