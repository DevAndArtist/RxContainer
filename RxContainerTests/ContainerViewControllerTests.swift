//
//  ContainerViewControllerTests.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 05.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

@testable import RxContainer
import RxSwift
import XCTest

class ContainerViewControllerTests : XCTestCase {

	var containerViewController = ContainerViewController()
    
    override func setUp() {
        super.setUp()
		self.containerViewController = ContainerViewController()
    }

	func testIfStackIsEmptyAtInit() {
		XCTAssertTrue(self.containerViewController.viewControllers.isEmpty,
		              "View controller stack should be empty at init")
	}

	func testStackEqualityVariadicInit() {
		// Create two view controllers to test
		let firstVC = UIViewController()
		let secondVC = UIViewController()
		// Instantiate a new container view controller and pass both VC's to it's variadic init
		self.containerViewController = ContainerViewController(firstVC, secondVC)
		// Test if the stack is equal the following array
		let viewControllers = [firstVC, secondVC]
		XCTAssertTrue(self.containerViewController.viewControllers == viewControllers,
		              "View controller stack should be equal to the array")
	}

	func testStackEqualityForSetMethod() {
		// Create a view controller stack of two VC's
		let viewControllers = [UIViewController(), UIViewController()]
		// Set the whole stack on the current container view controller
		self.containerViewController.setViewControllers(viewControllers)
		// Test for equality
		XCTAssertTrue(self.containerViewController.viewControllers == viewControllers,
		              "View controller stack should be equal to the array")
	}

	func testCanAnimateTransition() {
		XCTAssertFalse(self.containerViewController.canAnimateTransition(),
		              "View controller stack is empty and therefore there cannot be an animated transition.")
		// Create a view controller stack of two VC's
		let viewControllers = [UIViewController(), UIViewController()]
		// Set the whole stack on the current container view controller
		self.containerViewController.setViewControllers(viewControllers)
		// Test when the stack is not empty
		XCTAssertTrue(self.containerViewController.canAnimateTransition(),
		              "View controller stack is not empty and therefore an animated transition can occur.")
	}

	func testSetEventDelivery() {
		// Create a view controller stacks of two VC's
		let viewControllers1 = [UIViewController(), UIViewController()]
		let viewControllers2 = [UIViewController(), UIViewController()]
		// Create a dispose bag for the following subscription
		let disposeBag = DisposeBag()
		// A variable to test delivery order
		var endCalledLast = false
		//
		var viewControllers1EventOccured = false
		// Register pseudo delegate before calling the `set` method
		self.containerViewController
			.events
			.subscribe(onNext: {
				// Test the event for `viewControllers2`
				if $0.position == .start {
					XCTAssertTrue($0.containerViewController.viewControllers != viewControllers2,
					              "The view controller stack was set before `.start` event.")
					endCalledLast = false
				} else {
					XCTAssertTrue($0.containerViewController.viewControllers == viewControllers2,
					              "The view controller stack was not set before `.end` event.")
					endCalledLast = true
				}
				// Test if the stack from the event was `viewControllers1`
				if case .set(let stack) = $0.operation.kind {
					viewControllers1EventOccured = stack == viewControllers1
				}
			})
			.disposed(by: disposeBag)

		XCTAssertTrue(self.containerViewController.viewControllers.isEmpty)
		// Set the whole stack on the current container view controller
		self.containerViewController.setViewControllers(viewControllers1)
		XCTAssertFalse(viewControllers1EventOccured,
		               "A wrong set event occured.")
		XCTAssertTrue(self.containerViewController.viewControllers == viewControllers1,
		              "View controller stack was not set correctly without an event.")
		// Re-set the whole stack on the current container view controller
		self.containerViewController.setViewControllers(viewControllers2)
		XCTAssertTrue(endCalledLast,
		              "View controller stack was not set correctly after the set event.")
	}
}
