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
	var viewControllerStack = [UIViewController]()
	let disposeBag = DisposeBag()
	let eventsSubject = PublishSubject<ContainerViewController.Event>()

	// open/public properties
	/// The view controllers currently on the view controller stack.
	///
	/// The root view controller is at index `0` in the array and the 
	/// top controller is at index n-1, where n is the number of items
	/// in the array.
	///
	/// Assigning a new array of view controllers to this property is 
	/// equivalent to calling the `setViewControllers(_:animated:)` 
	/// method with the `animated` parameter set to `false`.
	open var viewControllers: [UIViewController] {
		get { return self.viewControllerStack }
		set { self.setViewControllers(newValue, animated: false) }
	}

	/// The root view controller of the view controller stack.
	open var rootViewController: UIViewController? {
		return self.viewControllers.first
	}

	/// The view controller at the top of the view controller stack.
	open var topViewController: UIViewController? {
		return self.viewControllers.last
	}

	/// Once the syntax sugar from [SE-0111 commentary
	/// ](https://lists.swift.org/pipermail/swift-evolution-announce/2016-July/000233.html)
	/// made into the language, this closure will become either
	///
	///    - `var animator(for:): (Transition) -> Animator?`
	///
	/// or
	///
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

	/// Initializes and returns a newly created container view controller.
	///
	/// This is a convenience method for initializing the receiver and
	/// pushing view controllers onto the view controller stack. Every
	/// view controller stack must have at least one view controller to 
	/// act as the root.
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
