//
//  Transition.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 04.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

public final class Transition {

	public enum CompletionPosition {
		case start, end
	}

	var transitionCompletion: ( /* @escaping */ (CompletionPosition) -> Void)?

	///
	public private(set) var animation: ( /* @escaping */ (Context) -> Void)?

	///
	public private(set) var completion: ( /* @escaping */ (Context) -> Void)?

	///
	public let context: Context

	///
	public let containerViewController: ContainerViewController

	///
	init(with context: Context, on containerViewController: ContainerViewController) {
		self.context = context
		self.containerViewController = containerViewController
	}

	///
	public func animateAlongside(_ animation: ( /* @escaping */ (Context) -> Void)?,
	                             completion: ( /* @escaping */ (Context) -> Void)? = nil) {
		self.animation = animation
		self.completion = completion
	}

	///
	public func complete(at position: CompletionPosition) {
		self.transitionCompletion?(position)
	}
}
