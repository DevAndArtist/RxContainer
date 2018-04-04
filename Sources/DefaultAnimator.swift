//
//  DefaultAnimator.swift
//  RxContainer
//
//  Created by Adrian Zubarev on 13.06.17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit

///
public final class DefaultAnimator : Animator {

  //==========-----------------------------==========//
  //=====----- Private/Internal properties -----=====//
  //==========-----------------------------==========//

  ///
  private lazy var context = transition.context

  ///
  private var additionalAnimation: ((Transition.Context) -> Void)? {
    return transition.additionalAnimation
  }

  ///
  private var additionalCompletion: ((Transition.Context) -> Void)? {
    return transition.additionalCompletion
  }

  ///
  private let layoutGuide = UILayoutGuide()

  ///
  private let overlayView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    view.isUserInteractionEnabled = false
    return view
  }()

  ///
  private lazy var containerView: UIView = context.containerView

  ///
  private lazy var fromView = context.view(forKey: .from)

  ///
   private lazy var toView = context.view(forKey: .to)

  ///
  private lazy var shouldPush = context.kind == (
    order == .normal ? .push : .pop
  )

  ///
  private var shouldPop: Bool { return !shouldPush }

  ///
  private var views: [UIView] {
    // Return in correct order depending on the kind of the transition context
    if shouldPush {
      return [fromView, overlayView, toView]
    }
    return [toView, overlayView, fromView]
  }

  ///
  private let factor = CGFloat(0.3)

  ///
  private var constraintToDeactivate: NSLayoutConstraint?

  ///
  private let propertyAnimator = UIViewPropertyAnimator(
    duration: 0.4, curve: .easeInOut
  )

  ///
  private var progressWhenInterrupted = CGFloat(0)

  //==========------------------------==========//
  //=====----- Open/Public properties -----=====//
  //==========------------------------==========//

  ///
  public let transition: Transition

  ///
  public let direction: Direction

  ///
  public let style: Style

  ///
  public let order: Order

  //==========-------------==========//
  //=====----- Initializer -----=====//
  //==========-------------==========//

  ///
  public init(for transition: Transition,
              withDirection direction: Direction,
              style: Style = .overlap,
              order: Order = .normal) {
    self.transition = transition
    self.direction = direction
    self.style = style
    self.order = order
  }
}

extension DefaultAnimator {
  ///
  public func animate() {
    //
    UIView.performWithoutAnimation(preTransitionState)
    //
    let animation = postTransitionState()
    //
    if context.isAnimated {
      propertyAnimator.addAnimations(animation)
      propertyAnimator.addCompletion(completeTransition)
      propertyAnimator.startAnimation()
      //
      guard context.isInteractive else { return }
      let action: (UIPanGestureRecognizer) -> Void = { [weak self] in
        guard let animator = self else { return }
        let signValue: CGFloat = animator.direction.isLeftOrUp ? -1 : 1
        let isDirectionHorizontal = animator.direction == .left
          || animator.direction == .right
        let propertyAnimator = animator.propertyAnimator
        switch $0.state {
        case .began:
          propertyAnimator.pauseAnimation()
          animator.progressWhenInterrupted = propertyAnimator.fractionComplete
        case .changed:
          propertyAnimator.isRunning.whenTrue(
            execute: propertyAnimator.pauseAnimation
          )
          let point = $0.translation(in: animator.containerView)
          let frame = animator.containerView.frame
          let size = isDirectionHorizontal ? frame.width : frame.height
          let translation = signValue * (
            isDirectionHorizontal ? point.x : point.y
          )
          let progress = translation / size + animator.progressWhenInterrupted
          propertyAnimator.fractionComplete = progress
        default:
          let point = $0.velocity(in: animator.containerView)
          let velocity = signValue * (isDirectionHorizontal ? point.x : point.y)
          let progress = propertyAnimator.fractionComplete
          let shouldReverse = progress < 0.5 && velocity < 100
            || velocity < -100
          propertyAnimator.isReversed = shouldReverse
          propertyAnimator.continueAnimation(
            withTimingParameters: nil, durationFactor: 0
          )
        }
      }
      // If there was an interactive push, then it is assumed that the
      // fromView will have a gesture recognizer already attatched to it.
      // Otherwise the push was animated or immediate, which means we have
      // to attatch a new gesture to fromView to make the pop transition
      // interruptible.
      //
      // On the other hand the interactive push will attatch a gesture
      // to the toView.
      if shouldPop, let gesture = gestureInView(forKey: .from) {
        gesture.action = action
      } else {
        let view = shouldPop ? fromView : toView
        view.addGestureRecognizer(PanGestureRecognizer(with: action))
      }
    } else {
      UIView.performWithoutAnimation(animation)
      completeTransition(at: .end)
    }
  }
}

extension DefaultAnimator {
  ///
  private func deactivateAndRemoveSavedConstraint() {
    if let constraint = constraintToDeactivate {
      NSLayoutConstraint.deactivate([constraint])
      constraintToDeactivate = nil
    }
  }

  ///
  private func setupLayoutGuide() {
    containerView.addLayoutGuide(layoutGuide)
    let constraints = [
      layoutGuide.widthAnchor
        .constraint(equalTo: containerView.widthAnchor, multiplier: 2),
      layoutGuide.heightAnchor
        .constraint(equalTo: containerView.heightAnchor, multiplier: 2),
      layoutGuide.centerXAnchor
        .constraint(equalTo: containerView.centerXAnchor),
      layoutGuide.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }

  ///
  private func setupViews() {
    //
    views.forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      containerView.addSubview($0)

      var constraints: [NSLayoutConstraint] = [
        $0.widthAnchor.constraint(equalTo: containerView.widthAnchor),
        $0.heightAnchor.constraint(equalTo: containerView.heightAnchor)
      ]

      let lowerPriorityConstraints: [NSLayoutConstraint] = [
        $0.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        $0.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        $0.topAnchor.constraint(equalTo: containerView.topAnchor),
        $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
      ]
      lowerPriorityConstraints.forEach {
        // Lower the priority of these constraints, so we don't have to
        // remove them. Other constraints with higher priorty will take
        // over them when needed.
        $0.priority = .defaultLow
        constraints.append($0)
      }
      NSLayoutConstraint.activate(constraints)
    }
    // Remove the overlay view from the slide transition
    (style == .slide).whenTrue(execute: overlayView.removeFromSuperview)
  }

  ///
  private func preTransitionState() {
    // Since the animator is responsible to handle the subviews,
    // we have to remove all subviews first.
    containerView.subviews.forEach {
      $0.removeFromSuperview()
    }
    //
    setupLayoutGuide()
    setupViews()
    //
    let shouldOverlap = style == .overlap
    //
    let constraint: NSLayoutConstraint
    switch direction {
    case .left, .right:
      let (anchorForPop, centerXAnchor): (
        NSLayoutXAxisAnchor, NSLayoutXAxisAnchor
      )
      if direction.isLeftOrUp {
        anchorForPop = shouldOverlap
          ? containerView.trailingAnchor
          : layoutGuide.trailingAnchor
        centerXAnchor = shouldPush ? layoutGuide.trailingAnchor : anchorForPop
      } else {
        anchorForPop = shouldOverlap
          ? containerView.leadingAnchor
          : layoutGuide.leadingAnchor
        centerXAnchor = shouldPush ? layoutGuide.leadingAnchor : anchorForPop
      }
      constraint = toView.centerXAnchor.constraint(equalTo: centerXAnchor)
    case .up, .down:
      let (anchorForPop, centerYAnchor): (
        NSLayoutYAxisAnchor, NSLayoutYAxisAnchor
      )
      if direction.isLeftOrUp {
        anchorForPop = shouldOverlap
          ? containerView.centerYAnchor
          : layoutGuide.bottomAnchor
        centerYAnchor = shouldPush
          ? layoutGuide.bottomAnchor
          : anchorForPop
      } else {
        anchorForPop = shouldOverlap
          ? containerView.centerYAnchor
          : layoutGuide.topAnchor
        centerYAnchor = shouldPush ? layoutGuide.topAnchor : anchorForPop
      }
      constraint = toView.centerYAnchor.constraint(equalTo: centerYAnchor)
    }
    constraint.isActive = true
    constraintToDeactivate = constraint
    //
    overlayView.alpha = shouldPush ? 0 : 1
    // Force update
    containerView.layoutIfNeeded()
  }

  ///
  private func postTransitionState() -> () -> Void {
    //
    let shouldOverlap = style == .overlap
    //
    let constraint: NSLayoutConstraint
    switch direction {
    case .left, .right:
      let (anchorForPush, centerXAnchor): (
        NSLayoutXAxisAnchor, NSLayoutXAxisAnchor
      )
      if direction.isLeftOrUp {
        anchorForPush = shouldOverlap
          ? containerView.leadingAnchor
          : layoutGuide.leadingAnchor
        centerXAnchor = shouldPush ? anchorForPush : layoutGuide.leadingAnchor
      } else {
        anchorForPush = shouldOverlap
          ? containerView.trailingAnchor
          : layoutGuide.trailingAnchor
        centerXAnchor = shouldPush ? anchorForPush : layoutGuide.trailingAnchor
      }
      constraint = fromView.centerXAnchor.constraint(equalTo: centerXAnchor)
    case .up, .down:
      let (anchorForPush, centerYAnchor): (
        NSLayoutYAxisAnchor, NSLayoutYAxisAnchor
      )
      if direction.isLeftOrUp {
        anchorForPush = shouldOverlap
          ? containerView.centerYAnchor
          : layoutGuide.topAnchor
        centerYAnchor = shouldPush ? anchorForPush : layoutGuide.topAnchor
      } else {
        anchorForPush = shouldOverlap
          ? containerView.centerYAnchor
          : layoutGuide.bottomAnchor
        centerYAnchor = shouldPush ? anchorForPush : layoutGuide.bottomAnchor
      }
      constraint = fromView.centerYAnchor.constraint(equalTo: centerYAnchor)
    }
    constraint.isActive = true
    // First deactivate the constraint for the toView, so that the
    // animation can be generated.
    deactivateAndRemoveSavedConstraint()
    // Now safe the constraint for the fromView, which should be
    // deactivated on completion.
    constraintToDeactivate = constraint
    // Disallow touches on the toView while pop transition is executing
    shouldPop.whenTrue(execute: toView.isUserInteractionEnabled = false)
    return {
      self.containerView.layoutIfNeeded()
      self.overlayView.alpha = self.shouldPush ? 1 : 0
      self.additionalAnimation?(self.context)
    }
  }

  ///
  private func completeTransition(at position: UIViewAnimatingPosition) {
    UIView.performWithoutAnimation {
      deactivateAndRemoveSavedConstraint()
      overlayView.removeFromSuperview()
      containerView.removeLayoutGuide(layoutGuide)
      //
      shouldPop.whenTrue(execute: toView.isUserInteractionEnabled = true)
      //
      let containerViewController = transition.containerViewController
      let action: (UIPanGestureRecognizer) -> Void = {
        [weak containerViewController] in
        if $0.state == .began {
          containerViewController?.pop(option: .interactive)
        }
      }
      //
      switch position {
      case .start:
        if shouldPop {
          gestureInView(forKey: .from)?.action = action
        } else if shouldPush, let gesture = gestureInView(forKey: .to) {
          toView.removeGestureRecognizer(gesture)
        }
        toView.removeFromSuperview()
        transition.complete(at: .start)
      case .end:
        if shouldPush && context.isInteractive {
          gestureInView(forKey: .to)?.action = action
        } else if shouldPop, let gesture = gestureInView(forKey: .from) {
          fromView.removeGestureRecognizer(gesture)
        }
        fromView.removeFromSuperview()
        additionalCompletion?(context)
        transition.complete(at: .end)
      case .current:
        fatalError("Transition should not stop somewhere in between")
      }
    }
  }

  ///
  private func gestureInView(
    forKey key: Transition.Context.Key
  ) -> PanGestureRecognizer? {
    return context.view(forKey: key)
      .gestureRecognizers?
      .compactMap { $0 as? PanGestureRecognizer }
      .first
  }
}

extension DefaultAnimator {
  ///
  public enum Direction {
    case left, right, up, down

    //==========-----------------------------==========//
    //=====----- Private/Internal properties -----=====//
    //==========-----------------------------==========//

    ///
    var isLeftOrUp: Bool {
      return self == .left || self == .up
    }
  }

  ///
  public enum Style {
    case overlap, slide
  }

  ///
  public enum Order {
    case normal, reversed
  }
}
