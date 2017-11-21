//
//  Event.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension ContainerViewController {
	///
	public struct Event {
		
		//==========------------------------==========//
		//=====----- Open/Public properties -----=====//
		//==========------------------------==========//
		
		///
		public let operation: Operation

		///
		public internal(set) var position: Position

		///
		public let containerViewController: ContainerViewController
		
		//==========-------------==========//
		//=====----- Initializer -----=====//
		//==========-------------==========//

		///
		init(operation: Operation, position: Position, containerViewController: ContainerViewController) {
			self.operation = operation
			self.position = position
			self.containerViewController = containerViewController
		}
	}
}

extension ContainerViewController.Event {
	///
	public enum Position { case start, end }
}
