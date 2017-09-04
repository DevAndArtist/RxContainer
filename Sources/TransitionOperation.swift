//
//  TransitionOperation.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
final class TransitionOperation : Operation {
	
	//==========-----------------------------==========//
	//=====----- Private/Internal properties -----=====//
	//==========-----------------------------==========//
	
	///
	private let animator: Animator

	///
	private var isCurrentlyExecuting = false

	///
	private var didFinished = false
	
	//==========----------------------------==========//
	//=====----- Overriden super properties -----=====//
	//==========----------------------------==========//

	///
	override var isAsynchronous: Bool {
		return true
	}

	///
	override var isExecuting: Bool {
		get { return isCurrentlyExecuting }
		set {
			let key = "isExecuting"
			willChangeValue(forKey: key)
			isCurrentlyExecuting = newValue
			didChangeValue(forKey: key)
		}
	}

	///
	override var isFinished: Bool {
		get { return didFinished }
		set {
			let key = "isFinished"
			willChangeValue(forKey: key)
			didFinished = newValue
			didChangeValue(forKey: key)
		}
	}
	
	//==========-------------==========//
	//=====----- Initializer -----=====//
	//==========-------------==========//

	///
	init(with animator: Animator) {
		self.animator = animator
	}
}

extension TransitionOperation {
	///
	override func start() {
		isExecuting = true
		// The operation will only terminate if the animator called
		// `transition.complete(_:)` correctly, which will trigger
		// the `transitionCompletion` block that contains
		// `operation.isFinished = true`
		animator.animate()
	}
}
