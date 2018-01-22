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

  let containerViewController = ContainerViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .orange

    addChildViewController(containerViewController)
    let containerView: UIView = containerViewController.view
    containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
    containerView.center = view.center
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
    view.addSubview(containerView)
    containerViewController.didMove(toParentViewController: self)

    startTransitions()
  }

  func startTransitions() {
    let firstVC = UIViewController()
    firstVC.view.backgroundColor = .green

    let secondVC = UIViewController()
    secondVC.view.backgroundColor = .yellow

    let thirdVC = UIViewController()
    thirdVC.view.backgroundColor = .magenta

    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      self.containerViewController.push(firstVC) // Without animation
      self.containerViewController.push(secondVC) // First transition
      // Second transition after the first is done
      self.containerViewController.push(thirdVC)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
      self.containerViewController.pop() // 3rd transition
      self.containerViewController.pop() // 4th transition
      self.containerViewController.pop() // no-op
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
      // Push transition
      self.containerViewController.setViewControllers(
        [firstVC, secondVC, thirdVC]
      )
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 24) {
      self.containerViewController.pop()
      self.containerViewController.pop()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
      self.containerViewController.setViewControllers(
        [firstVC, secondVC, thirdVC]
      )
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 34) {
      self.containerViewController.popToRootViewController()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 38) {
      self.containerViewController.push(secondVC, option: .immediate)
      self.containerViewController.push(thirdVC, option: .interactive)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 42) {
      self.containerViewController
        .setViewControllers([firstVC], option: .immediate)
      self.containerViewController.setViewControllers([firstVC])
      self.containerViewController.pop(to: firstVC)
    }
  }
}
