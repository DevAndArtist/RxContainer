//
//  RotationOperation.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 18.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
final class RotationOperation : Operation {

	///
	private var _isExecuting = false

	///
	private var _isFinished = false

	///
	override var isAsynchronous: Bool {
		return true
	}

	///
	override var isExecuting: Bool {
		get { return _isExecuting }
		set {
			let key = "isExecuting"
			self.willChangeValue(forKey: key)
			self._isExecuting = newValue
			self.didChangeValue(forKey: key)
		}
	}

	///
	override var isFinished: Bool {
		get { return _isFinished }
		set {
			let key = "isFinished"
			self.willChangeValue(forKey: key)
			self._isFinished = newValue
			self.didChangeValue(forKey: key)
		}
	}

	///
	override func start() {
		self.isExecuting = true
	}
}
