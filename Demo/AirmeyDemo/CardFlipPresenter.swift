//
//  CardFlipPresenter.swift
//  TransitionTest
//
//  Created by chao on 2023/4/3.
//

import UIKit
import Airmey

public class CardFlipPresenter: AMPresenter {
    weak var flipView: UIView?
    weak var bottomView: UIView?
    
    private let initFrame: CGRect
    private let initImageView = UIImageView()
    private weak var initView: UIView?
    private var dimmingView = UIView()
    
    public init(initView: UIView?) {
        self.initView = initView
        self.initFrame = initView?.superview!.convert(initView?.frame ?? .zero, to: nil) ?? .zero
        self.initImageView.image = initView?.screenShotView()
        super.init()
        self.transitionDuration = 0.3
    }
    
    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if flipView == nil {
            return
        }
        
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }

        let toView = toVC.view!
        let duration = transitionDuration(using: transitionContext)

        if toVC.isBeingPresented{
            containerView.addSubview(toView)
            toView.frame = containerView.bounds
            
            dimmingView.frame = containerView.bounds
            containerView.insertSubview(dimmingView, at: 0)
            dimmingView.backgroundColor = .black.withAlphaComponent(0.0)
            
            initImageView.frame = initFrame
            containerView.addSubview(initImageView)
            
            initView?.alpha = 0.0
            bottomView?.alpha = 0.0
            bottomView?.backgroundColor = .clear
            
            flipView?.alpha = 0.0
                    
            UIView.animate(withDuration: duration / 2.0,
                           delay: 0.0,
                           options: .curveEaseIn) {
                let t1 = CATransform3DScale(CATransform3DIdentity,
                                            self.flipView!.bounds.width / self.initFrame.width / 2.0,
                                            self.flipView!.bounds.height / self.initFrame.height / 2.0,
                                            1.0)
                let t2 = CATransform3DTranslate(CATransform3DIdentity,
                                                (self.flipView!.bounds.midX - self.initFrame.midX) / 2.0,
                                                (self.flipView!.bounds.midY - self.initFrame.midY) / 2.0,
                                                0.0)
                let t3 = self.get3DTransform(angle: .pi/2.0)
                let t4 = CATransform3DConcat(CATransform3DConcat(t1, t3), t2)
                self.initImageView.transform3D = t4
            } completion: { _ in
                self.initImageView.isHidden = true

                let t1 = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 1.0)
                let t2 = CATransform3DTranslate(CATransform3DIdentity,
                                                (self.initFrame.midX - self.flipView!.bounds.midX) / 2.0,
                                                (self.initFrame.midY - self.flipView!.bounds.midY) / 2.0,
                                                0.0)
                let t3 = self.get3DTransform(angle: -.pi/2.0)
                let t4 = CATransform3DConcat(CATransform3DConcat(t1, t3), t2)
                self.flipView?.alpha = 1.0
                self.flipView?.transform3D = t4
                UIView.animate(withDuration: duration / 2.0, delay: 0.0, options: .curveEaseOut) {
                    self.flipView?.transform3D = CATransform3DIdentity
                    self.dimmingView.backgroundColor = .black.withAlphaComponent(1.0)
                    self.bottomView?.alpha = 1.0
                    self.bottomView?.backgroundColor = .black
                } completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
        
        if fromVC.isBeingDismissed {
            self.bottomView?.backgroundColor = .clear
            UIView.animate(withDuration: duration / 2.0, delay: 0.0, options: .curveEaseIn) {
                let t1 = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 1.0)
                let t2 = CATransform3DTranslate(CATransform3DIdentity,
                                                (self.initFrame.midX - self.flipView!.bounds.midX) / 2.0,
                                                (self.initFrame.midY - self.flipView!.bounds.midY) / 2.0,
                                                0.0)
                let t3 = self.get3DTransform(angle: -.pi/2.0)
                let t4 = CATransform3DConcat(CATransform3DConcat(t1, t3), t2)
                self.flipView?.transform3D = t4
                self.dimmingView.backgroundColor = .black.withAlphaComponent(0.0)
            } completion: { _ in
                self.flipView?.isHidden = true
                self.initImageView.isHidden = false
                UIView.animate(withDuration: duration / 2.0, delay: 0.0, options: .curveEaseOut) {
                    self.initImageView.transform3D = CATransform3DIdentity
                    self.bottomView?.alpha = 0.0
                } completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
                // 防止动画最后闪烁问题
                UIView.animate(withDuration: 0.033, delay: duration / 2.0 - 0.034) {
                    self.initView?.alpha = 1.0
                }
            }
        }
    }
}

extension CardFlipPresenter {
    open override func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
    
    open override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if initView != nil {
            return self
        } else {
            return nil
        }
    }
    
    open override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if initView != nil {
            return self
        } else {
            return nil
        }
    }
}

extension CardFlipPresenter {
    func get3DTransform(angle: CGFloat) -> CATransform3D {
        var scaleTransform = CATransform3DIdentity
        scaleTransform.m34 = 1.0 / 800.0
        let rotateTransform = CATransform3DRotate(CATransform3DIdentity, angle, 0.0, 1.0, 0.0)
        return CATransform3DConcat(rotateTransform, scaleTransform)
    }
}

extension UIView {
    func screenShotView() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        //self.layer.render(in: UIGraphicsGetCurrentContext()!)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
