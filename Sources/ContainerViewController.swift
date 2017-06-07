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

	// internal/fileprivate/private properties
	fileprivate var viewControllerStack = [UIViewController]()
	let disposeBag = DisposeBag()
	let eventsSubject = PublishSubject<ContainerViewController.Event>()

	/// Once the syntax sugar from [SE-0111 commentary
	/// ](https://lists.swift.org/pipermail/swift-evolution-announce/2016-July/000233.html)
	/// made into the language, this closure will become either
	///
	///    - `open var animator(for:): (Transition) -> Animator?`
	///
	/// or
	///
	///    - `open var animator: (for: Transition) -> Animator?`
	private var animatorClosure /* (for:) */: (Transition) -> Animator? = { _ in return nil }

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

	open var events: Observable<ContainerViewController.Event> {
		return self.eventsSubject
		           .asObservable()
		           .observeOn(MainScheduler.instance)
	}

	/// This function is a getter placeholder for a closure which is not
	/// yet possible to express in Swift:
	///    - `open var animator: (for: Transition) -> Animator?`
	public func animator(for transition: Transition) -> Animator? {
		return self.animatorClosure(transition)
	}

	/// This property should only be used as a setter placeholder for 
	/// a closure which is not yet possible to express in Swift:
	///    - `open var animator: (for: Transition) -> Animator?`
	///
	/// WARNING: The getter will always result in a fatal error,
	/// use `animator(for:)` method as a getter instead.
	public var animator /* (for:) */: (Transition) -> Animator? {
		get { fatalError("Use `animator(for:)` instead") }
		set { self.animatorClosure = newValue }
	}

	/// Initializes and returns a newly created container view controller.
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
		// Ignore an empty stack
		if viewControllers.isEmpty { return }
		// Override `animated` value if needed
		let animated = self.canAnimateTransition() ? animated : false
		// Delegate set operation to an internal method
		self.performSet(viewControllers, animated: animated)
	}
}

extension ContainerViewController {

	func performSet(_ viewControllers: [UIViewController], animated: Bool) {
		// Crash if the provided stack is empty
		precondition(!viewControllers.isEmpty, "New view controller stack cannot be empty.")
		// Create new instances for consistency
		let (_, newStack) = (self.viewControllerStack, viewControllers)
		// Proceed with a transion if possible otherwise alter the stack directly
		// and drive with the default behaviour
		if self.canAnimateTransition() {
			// Create and fire a new set event
			var setEvent = Event(operation: Operation(kind: .set(newStack), isAnimated: animated),
			                     position: .start,
			                     containerViewController: self)
			self.eventsSubject.onNext(setEvent)
			// Alter the stack
			self.viewControllerStack = newStack
			// Alter the event position to `.ent` before firing a new one
			setEvent.position = .end
			self.eventsSubject.onNext(setEvent)
		} else {
			// Alter the stack
			self.viewControllerStack = newStack
		}
	}

	/// It is assumed that there should be no transion when the current
	/// view controller stack is empty as is about to be set.
	func canAnimateTransition() -> Bool {
		return !self.viewControllerStack.isEmpty
	}
}
