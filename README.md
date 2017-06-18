<p align="center"><img src="Resources/logo.png" /></p>
<p align="center">
	<img src="https://img.shields.io/badge/Language-Swift%203.1-orange.svg?style=flat-square&link=https://swift.org&link=https://github.com/apple/swift/blob/master/CHANGELOG.md"/>	
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

The API is future oriented, which means the following description is already using nested open protocols or default implementation in protocols even if these features are not currently possibble. However the module itself is wirtten so that it already behaves like written below.

##### ContainerViewController:

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
    
    @discardableResult
    open func pop(animated: Bool = default) -> UIViewController?
    
    @discardableResult
    open func pop(to viewController: UIViewController, animated: Bool = default) -> [UIViewController]?
    
    @discardableResult
    open func popToRootViewController(animated: Bool = default) -> [UIViewController]?
    
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = default)
}
```

##### Transition:

```swift 
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

    public func animateAlongside(_ animation: ((Context) -> Void)?, 
                                 completion: ((Context) -> Void)? = default)
    public func complete(_ didComplete: Bool)
}
```

##### Animator:

```swift
open protocol Animator : class {
    public var transition: Transition { get }
    public func animate()
    
    // Default implementation
    public func transition(completed: Bool) { /* no-op */}
}
```
##### DefaultAnimator:

```swift
public final class DefaultAnimator : Animator {

    public enum Direction { case left, right, up, down }

    public let transition: Transition
    public let direction: Direction
    public init(for transition: Transition, withDirection direction: Direction)
    public func animate()
}
```