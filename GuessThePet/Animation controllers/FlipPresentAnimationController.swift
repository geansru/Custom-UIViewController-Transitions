import UIKit

final class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let interval: TimeInterval = 0.5
  private let originFrame: CGRect
  
  init(originFrame: CGRect) {
    self.originFrame = originFrame
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return interval
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let from = transitionContext.viewController(forKey: .from),
          let to = transitionContext.viewController(forKey: .to),
          let snapshot = to.view.snapshotView(afterScreenUpdates: true)
      else {
        return
    }
    
    let containerView = transitionContext.containerView
    let finalFrame = transitionContext.finalFrame(for: to)
    
    
    snapshot.frame = originFrame
    snapshot.layer.cornerRadius = CardViewController.cardCornerRadius
    snapshot.layer.masksToBounds = true
    
    containerView.addSubview(to.view)
    containerView.addSubview(snapshot)
    to.view.isHidden = true
    
    AnimationHelper.perspectiveTransform(for: containerView)
    snapshot.layer.transform = AnimationHelper.yRotation(.pi/2)
    
    let animations = {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
        from.view.layer.transform = AnimationHelper.yRotation(-.pi/2)
      })
      UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
        snapshot.layer.transform = AnimationHelper.yRotation(0)
      })
      UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
        snapshot.frame = finalFrame
        snapshot.layer.cornerRadius = 0
      })
    }
    
    let completion = { (_: Bool) in
      to.view.isHidden = false
      snapshot.removeFromSuperview()
      from.view.layer.transform = CATransform3DIdentity
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    UIView.animateKeyframes(withDuration: interval, delay: 0, options: .calculationModeCubic, animations: animations, completion: completion)
  }
  
}
