//
//  Event.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {

	public struct Event {

		public enum Position { case start, end }

		public let operation: Operation
		public internal(set) var position: Position
		public let containerViewController: ContainerViewController

		init(operation: Operation, position: Position, containerViewController: ContainerViewController) {
			self.operation = operation
			self.position = position
			self.containerViewController = containerViewController
		}
	}
}
