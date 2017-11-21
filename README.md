<p align="center"><img src="Resources/logo.png" /></p>
<p align="center">
	<img src="https://img.shields.io/badge/Language-Swift%204.0-orange.svg?style=flat-square&link=https://swift.org&link=https://github.com/apple/swift/blob/master/CHANGELOG.md"/>	
	<img src="https://img.shields.io/cocoapods/v/RxContainer.svg?maxAge=120&label=Version&colorB=01A5EB&style=flat-square"/>
	<img src="https://img.shields.io/badge/License-MIT-ff5050.svg?maxAge=120&style=flat-square"/><br>
	<!---hide until linked correctly--
	<a href="https://travis-ci.org/DevAndArtist/RxContainer">
		<img src="http://img.shields.io/travis/DevAndArtist/RxContainer.svg?label=Travis%20CI&style=flat-square"/>
	</a><br>
	<a href="https://codecov.io/gh/DevAndArtist/RxContainer">
		<img src="https://img.shields.io/codecov/c/github/DevAndArtist/RxContainer.svg?label=Code%20coverage&style=flat-square"/>
	--->
	</a>
	<img src="https://img.shields.io/badge/Compatibility-Carthage%20%7C%20CocoaPods-a0a0a0.svg?maxAge=120&style=flat-square"/>
</p>

This Swift module introduces a minimal custom `ContainerViewController`, which does not contain any unnecessary APIs like `UINavigationViewController`, nor rely on any protocols such as `UIViewControllerTransitioningDelegate` etc. for custom transitions.

The end-user is resposible to create custom animators, by conforming to the minimal `Animator` protocol, which will drive the transitions on the container-view-controller.  The `ContainerViewController` has three different options for `pop` or `push` transitions: `animated`, `interactive` and `immediate`.

##### ContainerViewController:

```swift
open class ContainerViewController : UIViewController {
    ///
    open protocol Delegate : AnyObject {
        ///
        func animator(for transition: Transition) -> Animator?
    }

    ///
    public struct Event {
        ///
        public enum Position { case start, end }

        ///
        public let operation: Operation

        ///
        public var position: Position { get }

        ///
        public let containerViewController: ContainerViewController
    }

    ///
    public struct Operation {
        ///
        public enum Kind {
            case push(UIViewController)
            case pop(UIViewController)
            case set([UIViewController])
        }
        
        ///
        public let kind: Kind

        ///
        public let isAnimated: Bool
    }
    
    ///
    public enum Option {
        case animated, interactive, immediate
    }

    ///
    open var viewControllers: [UIViewController]

    ///
    open var rootViewController: UIViewController? { get }

    ///
    open var topViewController: UIViewController? { get }

    ///
    open weak var delegate: Delegate?

    /// Initializes and returns a newly created container view controller.
    public init()

    /// Initializes and returns a newly created container view controller.
    ///
    /// This is a convenience method for initializing the receiver and
    /// pushing view controllers onto the view controller stack. Every
    /// view controller stack must have at least one view controller to 
    /// act as the root.
    public convenience init(_ viewControllers: UIViewController...)

    /// Initializes and returns a newly created container view controller.
    ///
    /// This is a convenience method for initializing the receiver and
    /// pushing view controllers onto the view controller stack. Every
    /// view controller stack must have at least one view controller to 
    /// act as the root.
    public convenience init(_ viewControllers: [UIViewController])

    ///
    required public init?(coder aDecoder: NSCoder)

    ///
    open func push(_ viewController: UIViewController, 
                   option: Option = .animated, 
                   with animator: (Transition) -> Animator = RxContainer.animator(for:))
    
    ///
    @discardableResult
    open func pop(option: Option = .animated, 
                  with animator: (Transition) -> Animator = RxContainer.animator(for:)) -> UIViewController?
    
    ///
    @discardableResult
    open func pop(to viewController: UIViewController, 
                  option: Option = .animated,
                  with animator: (Transition) -> Animator = RxContainer.animator(for:)) -> [UIViewController]?
    
    ///
    @discardableResult
    open func popToRootViewController(option: Option = .animated,
                                      with animator: (Transition) -> Animator = RxContainer.animator(for:)) -> [UIViewController]?
    
    ///
    open func setViewControllers(_ viewControllers: [UIViewController], 
                                 option: Option = .animated,
                                 with animator: (Transition) -> Animator = RxContainer.animator(for:))
}
```

#### Reactive extension:

```swift
extension Reactive where Base : ContainerViewController {
	///
	public var event: Signal<ContainerViewController.Event>
}
```

##### Transition:

```swift 
public final class Transition {
    ///
    public enum CompletionPosition { case start, end }

    ///
    public struct Context {

        ///
        public enum Key { case from, to }

        ///
        public enum Kind { case push, pop }

        ///
        public let kind: Kind

        ///
        public let containerView: UIView

        ///
        public let isAnimated: Bool

        ///
        public let isInteractive: Bool

        ///
        public func viewController(forKey key: Key) -> UIViewController

        ///
        public func view(forKey key: Key) -> UIView
    }

    ///
    public var additionalAnimation: ((Context) -> Void)? { get }
    
    ///
    public var additionalCompletion: ((Context) -> Void)? { get }
    
    ///
    public let context: Context
    
    ///
    public func animateAlongside(_ animation: ((Context) -> Void)?)
    
    ///
    public func animateAlongside(_ animation: ((Context) -> Void)?, 
                                 completion: ((Context) -> Void)? = default)

    ///
    public func complete(at position: CompletionPosition)
}
```

##### Animator:

```swift
open protocol Animator : AnyObject {
    ///
    var transition: Transition { get }

    ///
    func animate()
    
    // Default implementation (no-op)
    func transition(completed: Bool)
}
```
##### DefaultAnimator:

```swift
public final class DefaultAnimator : Animator {
    ///
    public enum Direction { case left, right, up, down }

    ///
    public enum Style { case overlap, slide }    
    
    ///
    public enum Order { case normal, reversed }

    ///
    public let transition: Transition

    ///
    public let direction: Direction
    
    ///
    public let style: Style

    ///
    public let order: Order

    ///
    public init(for transition: Transition,
	            withDirection direction: Direction,
	            style: Style = .overlap,
	            order: Order = .normal)

    ///
    public func animate()
}

/// Default function for any transition.
public func animator(for transition: Transition) -> Animator
```