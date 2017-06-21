//
//  PanGestureRecognizer.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 20.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

final class PanGestureRecognizer : UIPanGestureRecognizer {

	var action: ( /* @escaping */ (UIPanGestureRecognizer) -> Void)?

	init(with action: ( /* @escaping */ (UIPanGestureRecognizer) -> Void)? = nil) {
		self.action = action
		super.init(target: nil, action: nil)
		self.maximumNumberOfTouches = 1
		self.addTarget(self, action: #selector(self.handlePan(_:)))
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		self.action?(gesture)
	}
}
