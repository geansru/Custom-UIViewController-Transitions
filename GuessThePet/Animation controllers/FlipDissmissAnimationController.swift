import UIKit

final class FlipDissmissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  let destinationFrame: CGRect
  let interactionController: SwipeInteractionController?
  
  init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
    self.destinationFrame = destinationFrame
    self.interactionController = interactionController
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let to = transitionContext.viewController(forKey: .to),
          let from = transitionContext.viewController(forKey: .from),
          let snapshot = from.view.snapshotView(afterScreenUpdates: false)
      else {
        return
    }
    
    snapshot.layer.cornerRadius = CardViewController.cardCornerRadius
    snapshot.layer.masksToBounds = true
    
    let containerView = transitionContext.containerView
    containerView.insertSubview(to.view, at: 0)
    containerView.addSubview(snapshot)
    from.view.isHidden = true
    
    AnimationHelper.perspectiveTransform(for: containerView)
    to.view.layer.transform = AnimationHelper.yRotation(-.pi/2)
    let duration = transitionDuration(using: transitionContext)
    
    let animations = {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
        snapshot.frame = self.destinationFrame
      })
      UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
        snapshot.layer.transform = AnimationHelper.yRotation(.pi/2)
      })
      UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
        to.view.layer.transform = AnimationHelper.yRotation(0)
      })
    }
    let comletion: (Bool) -> Void = { _ in
      from.view.isHidden = false
      snapshot.removeFromSuperview()
      if transitionContext.transitionWasCancelled {
        to.view.removeFromSuperview()
      }
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: animations, completion: comletion)
    
  }
  
}
