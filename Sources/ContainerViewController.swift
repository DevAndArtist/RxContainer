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
	///
	fileprivate var viewControllerStack = [UIViewController]()
	
	///
	let eventsSubject = PublishSubject<ContainerViewController.Event>()

	///
	let operationQueue: OperationQueue = {
		let queue = OperationQueue.main
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

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

	///
	open var events: Observable<ContainerViewController.Event> {
		return self.eventsSubject
		           .asObservable()
		           .observeOn(MainScheduler.instance)
	}

	///
	open weak var delegate: Delegate?

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

	///
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	deinit {
		// Complete the subject sequence
		self.eventsSubject.onCompleted()
	}
}

extension ContainerViewController {

	///
	open func push(_ viewController: UIViewController, animated: Bool = true) {

	}

	///
	@discardableResult
	open func pop(animated: Bool = true) -> UIViewController? {
		return nil
	}

	///
	@discardableResult
	open func pop(to viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
		return nil
	}

	///
	@discardableResult
	open func popToRootViewController(animated: Bool = true) -> [UIViewController]? {
		return nil
	}

	///
	open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = true) {
		// Ignore an empty stack
		if viewControllers.isEmpty { return }
		// Create new instances for consistency
		let (oldStack, newStack) = (self.viewControllerStack, viewControllers)
		// Proceed with a transion if possible otherwise alter the stack directly
		// and drive with the default behaviour
		if self.canAnimateTransition() {
			// Create and fire a new set event
			var event = Event(operation: Operation(kind: .set(newStack), isAnimated: animated),
			                  position: .start,
			                  containerViewController: self)
			self.eventsSubject.onNext(event)
			// Alter the stack
			self.viewControllerStack = newStack
			// Alter the event position to `.end` before firing a new one
			event.position = .end
			self.eventsSubject.onNext(event)
			// Extract view controllers for the transition
			guard let fromViewController = oldStack.last, let toViewController = newStack.last else { return }
			// Determin context kind
			let contextKind: Transition.Context.Kind = oldStack.contains(toViewController) ? .pop : .push
			// Instantiate a new context
			let context = Transition.Context(kind: contextKind,
			                                 containerView: self.view,
			                                 fromViewController: fromViewController,
			                                 toViewController: toViewController,
			                                 isAnimated: animated)
			// Create a transition
			let transition = Transition(with: context)
			//
			let direction: DefaultAnimator.Direction = contextKind == .push ? .left : .right
			// Get an animator for the transition
			let animator = self.delegate?
			                   .animator(for: transition) ?? DefaultAnimator(for: transition, withDirection: direction)
			// Create transition operation for the animator
			let operation = TransitionOperation(for: animator)
			// Prepare completion block
			transition.transitionCompletion = {
				[unowned animator, unowned operation] in
				animator.transition(completed: $0)
				// Finish operation to notify the queue
				operation.isFinished = true
			}
			// Push the operation onto the queue
			self.operationQueue.addOperation(operation)

		} else { self.performSetAfterInit(newStack) }
	}
}

extension ContainerViewController {

	///
	func performSetAfterInit(_ viewControllers: [UIViewController]) {
		// Crash if the provided stack is empty
		precondition(!viewControllers.isEmpty, "New view controller stack cannot be empty.")
		// Alter the stack
		self.viewControllerStack = viewControllers
		// Extract view controller
		guard let viewController = viewControllers.last else { return }
		let view: UIView = viewController.view
		view.autoresizingMask = .complete
		view.frame = self.view.bounds
		self.view.addSubview(view)
	}

	/// It is assumed that there should be no transion when the current
	/// view controller stack is empty as is about to be set.
	func canAnimateTransition() -> Bool {
		return !self.viewControllerStack.isEmpty
	}
}
