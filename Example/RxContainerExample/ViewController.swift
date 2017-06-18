//
//  ViewController.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 15.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import RxContainer
import UIKit

class ViewController : UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .orange

		let containerViewController = ContainerViewController()
		self.addChildViewController(containerViewController)
		let containerView: UIView = containerViewController.view
		containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
		containerView.center = self.view.center
		// Disable mask to see the animations but create a border
		containerView.layer.masksToBounds = false
		containerView.layer.borderWidth = 2
		containerView.layer.borderColor = UIColor.white.cgColor
		// Centered resizing mask
		containerView.autoresizingMask = [
			.flexibleTopMargin, .flexibleBottomMargin,
			.flexibleLeftMargin, .flexibleRightMargin
		]
		containerView.backgroundColor = .purple
		self.view.addSubview(containerView)
		containerViewController.didMove(toParentViewController: self)

		let firstVC = UIViewController()
		firstVC.view.backgroundColor = .green

		let secondVC = UIViewController()
		secondVC.view.backgroundColor = .yellow

		let thirdVC = UIViewController()
		thirdVC.view.backgroundColor = .magenta

		DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
			containerViewController.push(firstVC) // Without animation
			containerViewController.push(secondVC) // First transition
			containerViewController.push(thirdVC) // Second transition after the first is done
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
			containerViewController.pop() // 3rd transition
			containerViewController.pop() // 4th transition
			containerViewController.pop() // no-op
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
			// Push transition
			containerViewController.setViewControllers([firstVC, secondVC, thirdVC])
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 24) {
			containerViewController.pop()
			containerViewController.pop()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
			containerViewController.setViewControllers([firstVC, secondVC, thirdVC])
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 34) {
			containerViewController.popToRootViewController()
		}
	}
}
