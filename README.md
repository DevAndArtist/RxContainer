# RxContainer

### API

```swift
open class ContainerViewController : UIViewController {

    open protocol Delegate : class {
        func animator(for transition: Transition) -> Animator?
    }

    public struct Event {
        public enum Position { case start, end }

        public let operation: Operation
        public var position: Position { get }
        public let containerViewController: ContainerViewController
    }

    public struct Operation {

        public enum Kind {
            case push(UIViewController)
            case pop(UIViewController)
            case set([UIViewController])
        }

        public let kind: Kind
        public let isAnimated: Bool
    }

    open var viewControllers: [UIViewController]
    open var rootViewController: UIViewController? { get }
    open var topViewController: UIViewController? { get }
    open var events: RxSwift.Observable<ContainerViewController.Event> { get }
    open weak var delegate: Delegate?

    public init()
    public convenience init(_ viewControllers: UIViewController...)
    required public init?(coder aDecoder: NSCoder)

    open func push(_ viewController: UIViewController, animated: Bool = default)
    open func pop(animated: Bool = default) -> UIViewController?
    open func pop(to viewController: UIViewController, animated: Bool = default) -> [UIViewController]?
    open func popToRootViewController(animated: Bool = default) -> [UIViewController]?
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = default)
}

public protocol Animator : class {
    public var transition: Transition { get }
    public func animate()
    public func transition(completed: Bool)
}

extension Animator {
    public func transition(completed: Bool)
}

public final class DefaultAnimator : Animator {
    public enum Direction { case left, right, up, down }

    public let transition: Transition
    public let direction: Direction
    public init(for transition: Transition, withDirection direction: Direction)
    public func animate()
}

public final class Transition {

    public struct Context {
        public enum Key { case from, to }
        public enum Kind { case push, pop }

        public let kind: Kind
        public let containerView: UIView
        public let isAnimated: Bool
        public func viewController(forKey key: Key) -> UIViewController
        public func view(forKey key: Key) -> UIView
    }

    public var animation: ((Context) -> Void)? { get }
    public var completion: ((Context) -> Void)? { get }

    public let context: Context

    public func animateAlongside(_ animation: ((Context) -> Void)?, completion: ((Context) -> Void)? = default)
    public func complete(_ didComplete: Bool)
}
```