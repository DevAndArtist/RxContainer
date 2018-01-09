//
//  Delegate.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

/// WARNING: Do not use this protocol directly, instead use
/// `ContainerViewController.Delegate`.
///   - Once protocol nesting is supported this protocol will be nested
///     as `Animator` inside `ContainerViewController`.
public protocol _Delegate : AnyObject {
  ///
  func animator(for transition: Transition) -> Animator?
}

extension ContainerViewController {
  ///
  public typealias Delegate = _Delegate
}
