//
//  Extensions.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension UIViewAutoresizing {

	///
	static var complete: UIViewAutoresizing {
		return [
			.flexibleTopMargin,
			.flexibleBottomMargin,
			.flexibleLeftMargin,
			.flexibleRightMargin,
			.flexibleWidth,
			.flexibleHeight
		]
	}
}

prefix func ! <T>(closure: @escaping (T) -> Bool) -> (T) -> Bool {
	return { !closure($0) }
}
