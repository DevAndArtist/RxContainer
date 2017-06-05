//
//  Operation.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {

	public struct Operation {

		public enum Kind {
			case push(UIViewController)
			case pop(UIViewController)
			case set([UIViewController])
		}

		public let kind: Kind
		public let isAnimated: Bool

		init(kind: Kind, isAnimated: Bool) {
			self.kind = kind
			self.isAnimated = isAnimated
		}
	}
}
