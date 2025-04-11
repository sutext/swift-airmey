//
//  SheetModalPresentationAnimator.swift
//
//
//  Created by yongjun chen on 2023/2/20.
//

import UIKit
import Airmey

/**
 处理模态动画 presented & dismiss
 */

public class SheetModalPresentationAnimator: NSObject {

    public enum TransitionStyle {
        case presentation
        case dismissal
    }

    // MARK: - Properties

    private let transitionStyle: TransitionStyle

    /**
        震动器
     */
    private var feedbackGenerator: UISelectionFeedbackGenerator?

    // MARK: - Initializers

    required public init(transitionStyle: TransitionStyle) {
        self.transitionStyle = transitionStyle
        super.init()

        /**
         Prepare haptic feedback, only during the presentation state
         */
        if case .presentation = transitionStyle {
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
    }
    
    private func getPreviousViewController(transitionContext: UIViewControllerContextTransitioning) -> UIViewController? {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return nil
        }
        return (toVC.view.window as? AMWindowable)?.previousViewController
    }

    /**
     Animate presented view controller presentation
     */
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {

        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let presentable = sheetModalLayoutType(from: transitionContext)

        // Calls viewWillAppear and viewWillDisappear
        getPreviousViewController(transitionContext: transitionContext)?.beginAppearanceTransition(false, animated: true)
        
        // Presents the view in shortForm position, initially
        let yPos: CGFloat = (presentable?.shortFormYPos ?? 0.0)

        // Use panView as presentingView if it already exists within the containerView
        let panView: UIView = transitionContext.containerView.panContainerView ?? toVC.view

        // Move presented view offscreen (from the bottom)
//        panView.frame = transitionContext.finalFrame(for: toVC)
        panView.frame.origin.y = transitionContext.containerView.frame.height

        // Haptic feedback
        if presentable?.isHapticFeedbackEnabled == true {
            feedbackGenerator?.selectionChanged()
        }
        
        SheetModalAnimator.animate({
            panView.frame.origin.y = yPos
        }, config: presentable) { [weak self] didComplete in
            guard let self else { return }
            // Calls viewDidAppear and viewDidDisappear
            self.getPreviousViewController(transitionContext: transitionContext)?.endAppearanceTransition()
            transitionContext.completeTransition(true) /// fix background  didComplete false
            self.feedbackGenerator = nil
        }
    }

    /**
     Animate presented view controller dismissal
     */
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {

        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        // Calls viewWillAppear and viewWillDisappear
        /*
         Tips：previousViewController 不能函数捕获，在执行该函数期间可能释放，会导致无法释放问题
         */
        getPreviousViewController(transitionContext: transitionContext)?.beginAppearanceTransition(true, animated: true)
        
        let presentable = sheetModalLayoutType(from: transitionContext)
        let panView: UIView = transitionContext.containerView.panContainerView ?? fromVC.view

        SheetModalAnimator.animate({
            panView.frame.origin.y = transitionContext.containerView.frame.height
        }, config: presentable) { [weak self] didComplete in
            guard let self else { return }
            fromVC.view.removeFromSuperview()
            // Calls viewDidAppear and viewDidDisappear
            self.getPreviousViewController(transitionContext: transitionContext)?.endAppearanceTransition()
            transitionContext.completeTransition(true)
        }
    }

    /**
     Extracts the sheetModal from the transition context, if it exists
     */
    private func sheetModalLayoutType(from context: UIViewControllerContextTransitioning) -> SheetModalPresentable.LayoutType? {
        switch transitionStyle {
        case .presentation:
            return context.viewController(forKey: .to) as? SheetModalPresentable.LayoutType
        case .dismissal:
            return context.viewController(forKey: .from) as? SheetModalPresentable.LayoutType
        }
    }

}

// MARK: - UIViewControllerAnimatedTransitioning Delegate

extension SheetModalPresentationAnimator: UIViewControllerAnimatedTransitioning {

    /**
     Returns the transition duration
     */
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        guard
            let context = transitionContext,
            let presentable = sheetModalLayoutType(from: context)
            else { return SheetModalAnimator.Constants.defaultTransitionDuration }

        return presentable.transitionDuration
    }

    /**
     Performs the appropriate animation based on the transition style
     */
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .presentation:
            animatePresentation(transitionContext: transitionContext)
        case .dismissal:
            animateDismissal(transitionContext: transitionContext)
        }
    }
}
