//
//  ContainerViewController.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

open class ContainerViewController : UIViewController {

  //==========-----------------------------==========//
  //=====----- Private/Internal properties -----=====//
  //==========-----------------------------==========//

  ///
  private var viewControllerStack = [UIViewController]()

  ///
  fileprivate let rxEvent = PublishRelay<ContainerViewController.Event>()

  ///
  private let transitionQueue: OperationQueue = {
    let queue = OperationQueue.main
    queue.maxConcurrentOperationCount = 1
    return queue
  }()

  ///
  private let rotationQueue = OperationQueue()

  //==========------------------------==========//
  //=====----- Open/Public properties -----=====//
  //==========------------------------==========//

  ///
  open let containerView = UIView()

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
    get { return viewControllerStack }
    set { setViewControllers(newValue, option: .immediate) }
  }

  /// The root view controller of the view controller stack.
  open var rootViewController: UIViewController? {
    return viewControllers.first
  }

  /// The view controller at the top of the view controller stack.
  open var topViewController: UIViewController? {
    return viewControllers.last
  }

  ///
  open weak var delegate: Delegate?

  //==========-------------==========//
  //=====----- Initializer -----=====//
  //==========-------------==========//

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
    self.init(viewControllers)
  }

  /// Initializes and returns a newly created container view controller.
  ///
  /// This is a convenience method for initializing the receiver and
  /// pushing view controllers onto the view controller stack. Every
  /// view controller stack must have at least one view controller to
  /// act as the root.
  public convenience init(_ viewControllers: [UIViewController]) {
    self.init()
    self.viewControllers = viewControllers
  }

  ///
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  ///
  open override func viewDidLoad() {
    super.viewDidLoad()
    // Mask the view
    view.layer.masksToBounds = true
    //
    containerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerView)
    let constraints = [
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
    view.layoutIfNeeded()
  }

  ///
  open override func willTransition(
    to newCollection: UITraitCollection,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.willTransition(to: newCollection, with: coordinator)
    // Spawn new rotation operation
    let operation = RotationOperation()
    // Filter transitions which are not running
    let transitionOperations = transitionQueue.operations
      .flatMap { $0 as? TransitionOperation }
      .filter { !$0.isExecuting }
    // Force other transitions to wait until the rotation is done
    transitionOperations.forEach { $0.addDependency(operation) }
    //
    coordinator.animate(alongsideTransition: nil) { _ in
      operation.isFinished = true
    }
    //
    rotationQueue.addOperation(operation)
  }

  ///
  open override func show(_ viewController: UIViewController, sender: Any?) {
    push(
      viewController,
      option: UIView.areAnimationsEnabled ? .animated : .immediate
    )
  }

  ///
  open override func showDetailViewController(
    _ viewController: UIViewController, sender: Any?
  ) {
    show(viewController, sender: sender)
  }

  ///
  open override var shouldAutorotate: Bool {
    // Subclasses should not rotate when a transition is executing
    return !transitionQueue.operations.contains {
      ($0 as? TransitionOperation)?.isExecuting ?? false
    }
  }

  ///
  open func push(
    _ viewController: UIViewController,
    option: Option = .animated,
    with animator: (Transition) -> Animator = RxContainer.animator(for:)
  ) {
    //
    guard let fromViewController = topViewController else {
      return performSetAfterInit([viewController])
    }
    //
    precondition(!viewControllerStack.contains(viewController), """
      View controller stack already contanins <UIViewController: \
      \(String(format: "%p", viewController))>
      """)
    let sendEvents = {
      // Send events and manipulate the stack
      self.sendEvents(
        for: Operation(
          kind: .push(viewController),
          isAnimated: option.isAnimated
        )
      ) {
        self.viewControllerStack.append(viewController)
      }
      //
      self.addChildViewController(viewController)
    }
    //
    (!option.isInteractive).whenTrue(execute: sendEvents)
    // Create a new transition
    let newTransition = transition(
      .push, from: fromViewController, to: viewController, with: option
    )
    // Start transition
    startTransition(on: animator(newTransition)) {
      option.isInteractive.whenTrue(execute: sendEvents)
      viewController.didMove(toParentViewController: self)
    }
  }

  ///
  @discardableResult
  open func pop(
    option: Option = .animated,
    with animator: (Transition) -> Animator = RxContainer.animator(for:)
  ) -> UIViewController? {
    //
    guard viewControllerStack.count > 1 else { return nil }
    //
    let endIndex = viewControllerStack.endIndex
    let fromViewController = viewControllerStack[endIndex - 1]
    let toViewController = viewControllerStack[endIndex - 2]
    let sendEvents = {
      // Send events and manipulate the stack
      self.sendEvents(
        for: Operation(
          kind: .pop(fromViewController),
          isAnimated: option.isAnimated
        )
      ) {
        self.viewControllerStack.removeLast(1)
      }
      //
      fromViewController.willMove(toParentViewController: nil)
    }
    //
    (!option.isInteractive).whenTrue(execute: sendEvents)
    // Create a new transition
    let newTransition = transition(
      .pop, from: fromViewController, to: toViewController, with: option
    )
    // Start transition
    startTransition(on: animator(newTransition)) {
      option.isInteractive.whenTrue(execute: sendEvents)
      fromViewController.removeFromParentViewController()
    }
    return fromViewController
  }

  ///
  @discardableResult
  open func pop(
    to viewController: UIViewController,
    option: Option = .animated,
    with animator: (Transition) -> Animator = RxContainer.animator(for:)
  ) -> [UIViewController]? {
    //
    guard let position = viewControllerStack.index(of: viewController) else {
      fatalError("Cannot pop a view controller that is not on the stack")
    }
    // Get the top view controller from the stack
    let endIndex = viewControllerStack.endIndex
    let fromViewController = viewControllers[endIndex - 1]
    // Don't do anthing if the controllers are the same. For instance the
    // stack contains only the root view controller and the
    // `popToRootViewController(animated:)` method is called.
    if fromViewController === viewController { return nil }
    // Get the view controllers that we want to drop from the stack.
    let resultArray = Array(viewControllers.dropFirst(position + 1))
    //
    let sendEvents = {
      // Send events and manipulate the stack
      self.sendEvents(
        for: Operation(
          kind: .pop(fromViewController),
          isAnimated: option.isAnimated
        )
      ) {
        self.viewControllerStack.removeLast(resultArray.count)
      }
      // Notify all these controllers in the right order that they
      // will be removed.
      resultArray.reversed()
        .forEach { $0.willMove(toParentViewController: nil) }
    }
    //
    (!option.isInteractive).whenTrue(execute: sendEvents)
    // Create a new transition
    let newTransition = transition(
      .pop, from: fromViewController, to: viewController, with: option
    )
    // Start transition
    startTransition(on: animator(newTransition)) {
      option.isInteractive.whenTrue(execute: sendEvents)
      resultArray.reversed()
        .forEach { $0.removeFromParentViewController() }
    }
    return resultArray
  }

  ///
  @discardableResult
  open func popToRootViewController(
    option: Option = .animated,
    with animator: (Transition) -> Animator = RxContainer.animator(for:)
  ) -> [UIViewController]? {
    // Return `nil` if there is no root view controller yet
    guard let rootViewController = rootViewController else { return nil }
    // Use the `pop(to:animated)` method to finish the job
    return pop(to: rootViewController, option: option, with: animator)
  }

  ///
  open func setViewControllers(
    _ viewControllers: [UIViewController],
    option: Option = .animated,
    with animator: (Transition) -> Animator = RxContainer.animator(for:)
  ) {
    // Ignore an empty stack
    if viewControllers.isEmpty { return }
    // Create new instances for consistency
    let (oldStack, newStack) = (viewControllerStack, viewControllers)
    // Proceed with a transion if possible otherwise alter the stack directly
    // and drive with the default behaviour
    guard canAnimateTransition() else { return performSetAfterInit(newStack) }
    // Remove any view controller that is also inside the new stack,
    // because we don't need to notify these.
    // Also reverse the order for correct notifications order.
    let filteredOldStack = oldStack.filter(!newStack.contains).reversed()
    // Also filter the new stack to prevent wrong relationship events.
    let filteredNewStack = newStack.filter(!oldStack.contains)
    //
    let sendEvents = {
      // Send events and manipulate the stack
      self.sendEvents(
        for: Operation(
          kind: .set(newStack),
          isAnimated: option.isAnimated
        )
      ) {
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
    guard
      let fromViewController = oldStack.last,
      let toViewController = newStack.last
    else { return }
    // Determine context kind
    let kind: Transition.Context.Kind = oldStack.contains(toViewController)
      ? .pop
      : .push
    // Create a new transition
    let newTransition = transition(
      kind, from: fromViewController, to: toViewController, with: option
    )
    // Start transition
    startTransition(on: animator(newTransition)) {
      option.isInteractive.whenTrue(execute: sendEvents)
      // Remove only distinct view controllers
      filteredOldStack.forEach { $0.removeFromParentViewController() }
      // Notify only new linked view controllers
      filteredNewStack.forEach { $0.didMove(toParentViewController: self) }
    }
  }
}

extension ContainerViewController {
  ///
  private func startTransition(
    on animator: Animator, completion: @escaping () -> Void
  ) {
    if animator.transition.context.isAnimated {
      // Create transition operation for the animator
      let operation = TransitionOperation(with: animator)
      animator.add(operation: operation, completion: completion)
      // Push the operation onto the queue
      transitionQueue.addOperation(operation)
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
  private func transition(
    _ kind: Transition.Context.Kind,
    from fromViewController: UIViewController,
    to toViewController: UIViewController,
    with option: Option
  ) -> Transition {
    // Instantiate a new context
    let context = Transition.Context(
      kind: kind,
      containerView: containerView,
      fromViewController: fromViewController,
      toViewController: toViewController,
      option: option
    )
    // Create a transition
    return Transition(with: context, on: self)
  }

  ///
  private func sendEvents(
    for operation: Operation, stackManipulation: () -> Void
  ) {
    // Create and fire a new event
    var event = Event(
      operation: operation, position: .start, containerViewController: self
    )
    rxEvent.accept(event)
    // Alter the stack
    stackManipulation()
    // Alter the event position to `.end` before firing a new one
    event.position = .end
    rxEvent.accept(event)
  }

  ///
  private func performSetAfterInit(_ viewControllers: [UIViewController]) {
    // Crash if the provided stack is empty
    guard let viewController = viewControllers.last else {
      fatalError("New view controller stack cannot be empty.")
    }
    // Alter the stack
    viewControllerStack = viewControllers
    //
    viewControllers.forEach(addChildViewController)
    //
    let subview: UIView = viewController.view
    subview.autoresizingMask = .complete
    subview.translatesAutoresizingMaskIntoConstraints = true
    containerView.addSubview(subview)
    // Just in case
    UIView.performWithoutAnimation { subview.frame = containerView.bounds }
    // Finish without animation or transition
    viewController.didMove(toParentViewController: self)
  }

  /// It is assumed that there should be no transion when the current
  /// view controller stack is empty as is about to be set.
  func canAnimateTransition() -> Bool {
    return !viewControllerStack.isEmpty
  }
}

extension Reactive where Base : ContainerViewController {
  ///
  public var event: Signal<ContainerViewController.Event> {
    return base.rxEvent.asSignal()
  }
}
