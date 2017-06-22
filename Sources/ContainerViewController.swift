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
	let transitionQueue: OperationQueue = {
		let queue = OperationQueue.main
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

	///
	let rotationQueue = OperationQueue()

	// open/public properties
	/// The view controllers currently on the view controller stack.
	///
	/// The root view controller is at index `0` in the array and the 
	/// top controller is at index n-1, where n is the number of items
	/// in the array.
	///
	/// Assigning a new array of view controllers to this property is 
	/// equivalent to calling the `setViewControllers(_:option:)`
	/// method with the `option` parameter set to `.immediate`.
	open var viewControllers: [UIViewController] {
		get { return self.viewControllerStack }
		set { self.setViewControllers(newValue, option: .immediate) }
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
	open func push(_ viewController: UIViewController, option: Option = .animated) {
		//
		guard let fromViewController = self.topViewController else {
			return self.performSetAfterInit([viewController])
		}
		// Address for the view controller
		let address = String(format: "%p", viewController)
		//
		precondition(!self.viewControllerStack.contains(viewController),
		             "View controller stack already contanins <UIViewController: \(address)>")
		let sendEvents = {
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .push(viewController), isAnimated: option.isAnimated)) {
				self.viewControllerStack.append(viewController)
			}
			//
			self.addChildViewController(viewController)
		}
		//
		(!option.isInteractive).whenTrue(execute: sendEvents)
		// Create a new transition
		let transition = self.transition(ofKind: .push,
		                                 from: fromViewController,
		                                 to: viewController,
		                                 with: option)
		// Get an animator
		let animator = self.animator(for: transition)
		// Start transition
		self.startTransition(on: animator) {
			option.isInteractive.whenTrue(execute: sendEvents)
			viewController.didMove(toParentViewController: self)
		}
	}

	///
	@discardableResult
	open func pop(option: Option = .animated) -> UIViewController? {
		//
		guard self.viewControllerStack.count > 1 else { return nil }
		//
		let endIndex = self.viewControllerStack.endIndex
		let fromViewController = self.viewControllerStack[endIndex - 1]
		let toViewController = self.viewControllerStack[endIndex - 2]
		let sendEvents = {
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .pop(fromViewController), isAnimated: option.isAnimated)) {
				self.viewControllerStack.removeLast(1)
			}
			//
			fromViewController.willMove(toParentViewController: nil)
		}
		//
		(!option.isInteractive).whenTrue(execute: sendEvents)
		// Create a new transition
		let transition = self.transition(ofKind: .pop,
		                                 from: fromViewController,
		                                 to: toViewController,
		                                 with: option)
		// Get an animator
		let animator = self.animator(for: transition)
		// Start transition
		self.startTransition(on: animator) {
			option.isInteractive.whenTrue(execute: sendEvents)
			fromViewController.removeFromParentViewController()
		}
		return fromViewController
	}

	///
	@discardableResult
	open func pop(to viewController: UIViewController, option: Option = .animated) -> [UIViewController]? {
		//
		guard let position = self.viewControllerStack.index(of: viewController) else {
			fatalError("Cannot pop a view controller that is not on the stack")
		}
		// Get the top view controller from the stack
		let endIndex = self.viewControllerStack.endIndex
		let fromViewController = self.viewControllers[endIndex - 1]
		// Don't do anthing if the controllers are the same. For instance the stack contains only the
		// root view controller and the `popToRootViewController(animated:)` method is called.
		if fromViewController === viewController { return nil }
		// Get the view controllers that we want to drop from the stack.
		let resultArray = Array(self.viewControllers.dropFirst(position + 1))
		//
		let sendEvents = {
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .pop(fromViewController), isAnimated: option.isAnimated)) {
				self.viewControllerStack.removeLast(resultArray.count)
			}
			// Notify all these controllers in the right order that they will be removed.
			resultArray.reversed()
				.forEach { $0.willMove(toParentViewController: nil) }
		}
		//
		(!option.isInteractive).whenTrue(execute: sendEvents)
		// Create a new transition
		let transition = self.transition(ofKind: .pop,
		                                 from: fromViewController,
		                                 to: viewController,
		                                 with: option)
		// Get an animator
		let animator = self.animator(for: transition)
		// Start transition
		self.startTransition(on: animator) {
			option.isInteractive.whenTrue(execute: sendEvents)
			resultArray.reversed()
			           .forEach { $0.removeFromParentViewController() }
		}
		return resultArray
	}

	///
	@discardableResult
	open func popToRootViewController(option: Option = .animated) -> [UIViewController]? {
		// Return `nil` if there is no root view controller yet
		guard let rootViewController = self.rootViewController else { return nil }
		// Use the `pop(to:animated)` method to finish the job
		return self.pop(to: rootViewController, option: option)
	}

	///
	open func setViewControllers(_ viewControllers: [UIViewController], option: Option = .animated) {
		// Ignore an empty stack
		if viewControllers.isEmpty { return }
		// Create new instances for consistency
		let (oldStack, newStack) = (self.viewControllerStack, viewControllers)
		// Proceed with a transion if possible otherwise alter the stack directly
		// and drive with the default behaviour
		guard self.canAnimateTransition() else { return self.performSetAfterInit(newStack) }
		// Remove any view controller that is also inside the new stack,
		// because we don't need to notify these.
		// Also reverse the order for correct notifications order.
		let filteredOldStack = oldStack.filter(!newStack.contains).reversed()
		// Also filter the new stack to prevent wrong relationship events.
		let filteredNewStack = newStack.filter(!oldStack.contains)
		//
		let sendEvents = {
			// Send events and manipulate the stack
			self.sendEvents(for: Operation(kind: .set(newStack), isAnimated: option.isAnimated)) {
				self.viewControllerStack = newStack
			}
			// Notify only view controllers that will be removed from the stack
			filteredOldStack.forEach { $0.willMove(toParentViewController: nil) }
			// Link only new view controllers to self
			filteredNewStack.forEach(self.addChildViewController)
		}
		//
		(!option.isInteractive).whenTrue(execute: sendEvents)
		// Extract view controllers for the transition
		guard let fromViewController = oldStack.last, let toViewController = newStack.last else { return }
		// Determine context kind
		let kind: Transition.Context.Kind = oldStack.contains(toViewController) ? .pop : .push
		// Create a new transition
		let transition = self.transition(ofKind: kind,
		                                 from: fromViewController,
		                                 to: toViewController,
		                                 with: option)
		// Get an animator
		let animator = self.animator(for: transition)
		// Start transition
		self.startTransition(on: animator) {
			option.isInteractive.whenTrue(execute: sendEvents)
			// Remove only distinct view controllers
			filteredOldStack.forEach { $0.removeFromParentViewController() }
			// Notify only new linked view controllers
			filteredNewStack.forEach(UIViewController.didMove(self))
		}
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
			self.transitionQueue.addOperation(operation)
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
	                with option: Option) -> Transition {
		// Instantiate a new context
		let context = Transition.Context(kind: kind,
		                                 containerView: self.view,
		                                 fromViewController: fromViewController,
		                                 toViewController: toViewController,
		                                 option: option)
		// Create a transition
		return Transition(with: context, on: self)
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
	open override func viewDidLoad() {
		super.viewDidLoad()
		// Mask the view
		self.view.layer.masksToBounds = true
	}

	///
	open override func willTransition(to newCollection: UITraitCollection,
	                                  with coordinator: UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		// Spawn new rotation operation
		let operation = RotationOperation()
		// Filter transitions which are not running
		let transitionOperations = self.transitionQueue.operations
			.flatMap { $0 as? TransitionOperation }
			.filter { !$0.isExecuting }
		// Force other transitions to wait until the rotation is done
		transitionOperations.forEach { $0.addDependency(operation) }
		//
		coordinator.animate(alongsideTransition: nil) { _ in operation.isFinished = true }
		//
		self.rotationQueue.addOperation(operation)
	}

	///
	open override func show(_ viewController: UIViewController, sender: Any?) {
		self.push(viewController, option: UIView.areAnimationsEnabled ? .animated : .immediate)
	}

	///
	open override func showDetailViewController(_ viewController: UIViewController, sender: Any?) {
		self.show(viewController, sender: sender)
	}

	///
	open override var shouldAutorotate: Bool {
		// Subclasses should not rotate when a transition is executing
		return !self.transitionQueue.operations.contains { ($0 as? TransitionOperation)?.isExecuting ?? false }
	}
}
