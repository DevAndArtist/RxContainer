//
//  AppDelegate.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 15.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
  var window: UIWindow?
}

extension AppDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [
      UIApplicationLaunchOptionsKey: Any
    ]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = ViewController()
    window.makeKeyAndVisible()
    self.window = window
    return true
  }
}
