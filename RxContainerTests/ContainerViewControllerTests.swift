//
//  ContainerViewControllerTests.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 05.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

@testable import RxContainer
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
}
