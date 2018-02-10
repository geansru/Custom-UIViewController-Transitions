import UIKit

final class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
  var interactionInProgress = false
  
  private var shouldCompleteTransition = false
  private weak var viewController: UIViewController?
  
  init(viewController: UIViewController) {
    super.init()
    self.viewController = viewController
    prepareGestureRecognizer(in: viewController.view)
  }
  
  
  private func prepareGestureRecognizer(in view: UIView) {
    let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    gesture.edges = .left
    view.addGestureRecognizer(gesture)
  }
  
  @objc private func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
    guard let gestureRecognizerSuperView = gestureRecognizer.view?.superview,
          let viewController = viewController
      else { return }
    let translation = gestureRecognizer.translation(in: gestureRecognizerSuperView)
    var progress = (translation.x / 200)
    progress = CGFloat(fminf(fmaxf(Float(progress), 0), 1))
    
    switch gestureRecognizer.state {
    case .began:
      interactionInProgress = true
      viewController.dismiss(animated: true)
      
    case .changed:
      shouldCompleteTransition = progress > 0.5
      update(progress)
      
    case .cancelled:
      interactionInProgress = false
      cancel()
      
    case .ended:
      interactionInProgress = false
      shouldCompleteTransition
        ? finish()
        : cancel()
      
    case .failed, .possible:
      break
    }
  }
}
