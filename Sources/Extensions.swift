//
//  Extensions.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

extension UIView.AutoresizingMask {
  ///
  static var complete: UIView.AutoresizingMask {
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

extension Bool {
  ///
  func whenTrue(execute closure: () -> Void) {
    if self { closure() }
  }

  ///
  func whenTrue(execute closure: @autoclosure () -> Void) {
    if self { closure() }
  }
}
