//
//  ViewComponent.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation

/* closed */ protocol ViewComponent {

	func viewController(forKey key: ViewComponentKey) -> UIViewController
	func view(forKey key: ViewComponentKey) -> UIView
}
