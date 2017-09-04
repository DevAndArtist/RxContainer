//
//  PanGestureRecognizer.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 20.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

final class PanGestureRecognizer : UIPanGestureRecognizer {
	
	//==========-----------------------------==========//
	//=====----- Private/Internal properties -----=====//
	//==========-----------------------------==========//

	///
	var action: ((UIPanGestureRecognizer) -> Void)?
	
	//==========-------------==========//
	//=====----- Initializer -----=====//
	//==========-------------==========//

	///
	init(with action: ( /* @escaping */ (UIPanGestureRecognizer) -> Void)? = nil) {
		self.action = action
		super.init(target: nil, action: nil)
		maximumNumberOfTouches = 1
		addTarget(self, action: #selector(handlePan(_:)))
	}
}

extension PanGestureRecognizer {
	///
	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		action?(gesture)
	}
}
