//
//  RotationOperation.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 18.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
final class RotationOperation : Operation {

  //==========-----------------------------==========//
  //=====----- Private/Internal properties -----=====//
  //==========-----------------------------==========//

  ///
  private var isCurrentlyExecuting = false

  ///
  private var didFinished = false

  //==========----------------------------==========//
  //=====----- Overriden super properties -----=====//
  //==========----------------------------==========//

  ///
  override var isAsynchronous: Bool {
    return true
  }

  ///
  override var isExecuting: Bool {
    get { return isCurrentlyExecuting }
    set {
      let key = "isExecuting"
      willChangeValue(forKey: key)
      isCurrentlyExecuting = newValue
      didChangeValue(forKey: key)
    }
  }

  ///
  override var isFinished: Bool {
    get { return didFinished }
    set {
      let key = "isFinished"
      willChangeValue(forKey: key)
      didFinished = newValue
      didChangeValue(forKey: key)
    }
  }
}

extension RotationOperation {
  ///
  override func start() {
    isExecuting = true
  }
}
