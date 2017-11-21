//
//  Option.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 19.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {
	///
	public enum Option {
		case animated, interactive, immediate
		
		//==========-----------------------------==========//
		//=====----- Private/Internal properties -----=====//
		//==========-----------------------------==========//

		///
		var isInteractive: Bool {
			return self == .interactive
		}
		
		///
		var isAnimated: Bool {
			return self == .animated || isInteractive
		}
	}
}
