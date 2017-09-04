//
//  Transition.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

public final class Transition {

	//==========-----------------------------==========//
	//=====----- Private/Internal properties -----=====//
	//==========-----------------------------==========//
	
	///
	var transitionCompletion: ((CompletionPosition) -> Void)?
	
	//==========------------------------==========//
	//=====----- Open/Public properties -----=====//
	//==========------------------------==========//

	///
	public let context: Context

	///
	public let containerViewController: ContainerViewController
	
	///
	public private(set) var additionalAnimation: ((Context) -> Void)?
	
	///
	public private(set) var additionalCompletion: ((Context) -> Void)?
	
	//==========-------------==========//
	//=====----- Initializer -----=====//
	//==========-------------==========//

	///
	init(with context: Context, on containerViewController: ContainerViewController) {
		self.context = context
		self.containerViewController = containerViewController
	}
}

extension Transition {
	///
	public func animateAlongside(_ animation: ( /* @escaping */ (Context) -> Void)?,
	                             completion: ( /* @escaping */ (Context) -> Void)? = nil) {
		additionalAnimation = animation
		additionalCompletion = completion
	}
	
	///
	public func complete(at position: CompletionPosition) {
		transitionCompletion?(position)
	}
}

extension Transition {
	///
	public enum CompletionPosition { case start, end }
}
