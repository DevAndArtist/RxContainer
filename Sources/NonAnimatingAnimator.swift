//
//  NonAnimatingAnimator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation

import UIKit

final class NonAnimatingAnimator : Animator {
  ///
  let transition: Transition

  ///
  public init(for transition: Transition) {
    self.transition = transition
  }

  func animate() {
    UIView.performWithoutAnimation {
      transition.complete(at: .end)
    }
  }
}
