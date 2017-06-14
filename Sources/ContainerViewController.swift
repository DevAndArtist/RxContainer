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
		//
		if let fromViewController = self.topViewController {
			// Address for the view controller
			let address = String(format: "%p", viewController)
			//
			precondition(!self.viewControllerStack.contains(viewController),
			             "View controller stack already contanins <UIViewController: \(address)>")
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .push(viewController), isAnimated: animated)) {
				self.viewControllerStack.append(viewController)
			}
			//
			self.addChildViewController(viewController)
			// Create a new transition
			let transition = self.transition(ofKind: .push,
			                                 from: fromViewController,
			                                 to: viewController,
			                                 animated: animated)
			// Get an animator
			let animator = self.animator(for: transition)
			// Start transition
			self.startTransition(on: animator) {
				viewController.didMove(toParentViewController: self)
			}

		} else { self.performSetAfterInit([viewController]) }
	}

	///
	@discardableResult
	open func pop(animated: Bool = true) -> UIViewController? {
		//
		guard self.viewControllerStack.count > 1 else { return nil }
		//
		let endIndex = self.viewControllerStack.endIndex
		let fromViewController = self.viewControllerStack[endIndex - 1]
		let toViewController = self.viewControllerStack[endIndex - 2]
		// Send events and manipulate the stack
		self.sendEvents(for: Operation(kind: .pop(fromViewController), isAnimated: animated)) {
			self.viewControllerStack.removeLast(1)
		}
		//
		fromViewController.willMove(toParentViewController: nil)
		// Create a new transition
		let transition = self.transition(ofKind: .pop,
		                                 from: fromViewController,
		                                 to: toViewController,
		                                 animated: animated)
		// Get an animator
		let animator = self.animator(for: transition)
		// Start transition
		self.startTransition(on: animator) {
			fromViewController.removeFromParentViewController()
		}
		return fromViewController
	}

	///
	@discardableResult
	open func pop(to viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
		return nil
	}

	///
	@discardableResult
	open func popToRootViewController(animated: Bool = true) -> [UIViewController]? {
		// Return `nil` if there is no root view controller yet
		guard let rootViewController = self.rootViewController else { return nil }
		// Use the `pop(to:animated)` method to finish the job
		return self.pop(to: rootViewController, animated: animated)
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
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .set(newStack), isAnimated: animated)) {
				self.viewControllerStack = newStack
			}
			// Remove any view controller that is also inside the new stack,
			// because we don't need to notify these.
			// Also reverse the order for correct notifications order.
			let filteredOldStack = oldStack.filter(!newStack.contains).reversed()
			// Notify only view controllers that will be removed from the stack
			filteredOldStack.forEach { $0.willMove(toParentViewController: nil) }
			// Also filter the new stack to prevent wrong relationship events.
			let filteredNewStack = newStack.filter(!oldStack.contains)
			// Link only new view controllers to self
			filteredNewStack.forEach(self.addChildViewController)
			// Extract view controllers for the transition
			guard let fromViewController = oldStack.last, let toViewController = newStack.last else { return }
			// Determine context kind
			let kind: Transition.Context.Kind = oldStack.contains(toViewController) ? .pop : .push
			// Create a new transition
			let transition = self.transition(ofKind: kind,
			                                 from: fromViewController,
			                                 to: toViewController,
			                                 animated: animated)
			// Get an animator
			let animator = self.animator(for: transition)
			// Start transition
			self.startTransition(on: animator) {
				// Remove only distinct view controllers
				filteredOldStack.forEach { $0.removeFromParentViewController() }
				// Notify only new linked view controllers
				filteredNewStack.forEach(UIViewController.didMove(self))
			}

		} else { self.performSetAfterInit(newStack) }
	}
}

extension ContainerViewController {

	///
	func startTransition(on animator: Animator, completion: @escaping () -> Void) {
		if animator.transition.context.isAnimated {
			// Create transition operation for the animator
			let operation = TransitionOperation(with: animator)
			animator.add(operation: operation, completion: completion)
			// Push the operation onto the queue
			self.operationQueue.addOperation(operation)
		} else {
			// Add only the completion block and drive the transition
			// hopefully on the main thread by the animator
			animator.add(completion: completion)
			// The animator is responsible to handle correct the transition
			// without any animation
			animator.animate()
		}
	}

	///
	func animator(for transition: Transition) -> Animator {
		//
		let direction: DefaultAnimator.Direction = transition.context.kind == .push ? .left : .right
		// Get an animator for the transition
		return self.delegate?
		           .animator(for: transition) ?? DefaultAnimator(for: transition, withDirection: direction)
	}

	///
	func transition(ofKind kind: Transition.Context.Kind,
	                from fromViewController: UIViewController,
	                to toViewController: UIViewController,
	                animated: Bool) -> Transition {
		// Instantiate a new context
		let context = Transition.Context(kind: kind,
		                                 containerView: self.view,
		                                 fromViewController: fromViewController,
		                                 toViewController: toViewController,
		                                 isAnimated: animated)
		// Create a transition
		return Transition(with: context)
	}

	///
	func sendEvents(for operation: Operation, stackManipulation: () -> Void) {
		// Create and fire a new event
		var event = Event(operation: operation, position: .start, containerViewController: self)
		self.eventsSubject.onNext(event)
		// Alter the stack
		stackManipulation()
		// Alter the event position to `.end` before firing a new one
		event.position = .end
		self.eventsSubject.onNext(event)
	}

	///
	func performSetAfterInit(_ viewControllers: [UIViewController]) {
		// Crash if the provided stack is empty
		guard let viewController = viewControllers.last else {
			fatalError("New view controller stack cannot be empty.")
		}
		// Alter the stack
		self.viewControllerStack = viewControllers
		//
		viewControllers.forEach(self.addChildViewController)
		//
		let view: UIView = viewController.view
		view.autoresizingMask = .complete
		view.translatesAutoresizingMaskIntoConstraints = true
		self.view.addSubview(view)
		// Just in case
		UIView.performWithoutAnimation { view.frame = self.view.bounds }
		// Finish without animation or transition
		viewController.didMove(toParentViewController: self)
	}

	/// It is assumed that there should be no transion when the current
	/// view controller stack is empty as is about to be set.
	func canAnimateTransition() -> Bool {
		return !self.viewControllerStack.isEmpty
	}
}

extension ContainerViewController {

	///
	open override func show(_ viewController: UIViewController, sender: Any?) {
		self.push(viewController, animated: UIView.areAnimationsEnabled)
	}

	///
	open override func showDetailViewController(_ viewController: UIViewController, sender: Any?) {
		self.show(viewController, sender: sender)
	}
}
