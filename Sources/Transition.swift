//
//  Transition.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

public final class Transition {

	///
	public private(set) var animation: ((Context) -> Void)?

	///
	public private(set) var completion: ((Context) -> Void)?

	///
	public let context: Context

	///
	init(with context: Context) {
		self.context = context
	}

	///
	public func animateAlongside(_ animation: ( /* @escaping */ (Context) -> Void)?,
	                             completion: ( /* @escaping */ (Context) -> Void)? = nil) {
		self.animation = animation
		self.completion = completion
	}

	///
	public func complete(_ didComplete: Bool) {

	}
}
