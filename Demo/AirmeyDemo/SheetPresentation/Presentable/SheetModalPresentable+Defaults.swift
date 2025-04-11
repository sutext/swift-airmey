//
//  SheetModalPresentable+Defaults.swift
//
//
//  Created by yongjun chen on 2023/2/20.
//
import UIKit
import Airmey

/**
 Default values for the sheetModalPresentable.
 */
public extension SheetModalPresentable where Self: UIViewController {

    var topOffset: CGFloat {
        return .headerHeight
    }

    var shortFormHeight: SheetModalHeight {
        return longFormHeight
    }

    var longFormHeight: SheetModalHeight {
        guard let scrollView = panScrollable
            else { return .maxHeight }

        // called once during presentation and stored
        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }

    var cornerRadius: CGFloat {
        return 20
    }

    var springDamping: CGFloat {
        return 0.85
    }

    var transitionDuration: Double {
        return SheetModalAnimator.Constants.defaultTransitionDuration
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
    }

    var sheetModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.4)
    }

    var dragIndicatorBackgroundColor: UIColor {
//        return .background_black
        return .black
    }
    
    var topSafeAreaBackgroundColor: UIColor {
//        return .background_black
        return .black
    }
    
    var sheetModalBackgroundImage: UIImage? {
        return nil
    }

    var scrollIndicatorInsets: UIEdgeInsets {
        let top = shouldRoundTopCorners ? cornerRadius : 0
        return UIEdgeInsets(top: CGFloat(top), left: 0, bottom: .footerHeight, right: 0)
    }

    var anchorModalToLongForm: Bool {
        return true
    }

    var allowsExtendedPanScrolling: Bool {
        guard let scrollView = panScrollable
            else { return false }

        scrollView.layoutIfNeeded()
        return scrollView.contentSize.height > (scrollView.frame.height - .footerHeight)
    }

    var allowsDragToDismiss: Bool {
        return true
    }

    var allowsTapToDismiss: Bool {
        return true
    }

    var isUserInteractionEnabled: Bool {
        return true
    }

    var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    var enablePopOverBackground: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }

    var showDragIndicator: Bool {
        return shouldRoundTopCorners
    }
    
    var enableBottomView: Bool {
        shortFormYPos != longFormYPos
    }

    func shouldRespond(to sheetModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }

    func willRespond(to sheetModalGestureRecognizer: UIPanGestureRecognizer) {
    }

    func shouldTransition(to state: SheetModalPresentationController.PresentationState) -> Bool {
        return true
    }

    func shouldPrioritize(sheetModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }

    func willTransition(to state: SheetModalPresentationController.PresentationState) {

    }
    
    func willTransition(in topMaxPos: Bool) {
        _willTransition(in: topMaxPos)
    }

    func sheetModalWillDismiss() {

    }

    func sheetModalDidDismiss() {

    }
    
    func didTransition(to progress: Double) {

    }
    
    func didChangePanGesture(state: UIGestureRecognizer.State) {
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool? {
        return nil
    }
    
    
    // MARK: - intern
    func _willTransition(in topMaxPos: Bool) {
        let show = topMaxPos && enableBottomView
        if bottomView.isHidden == !show { return }
        if show {
            bottomView.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.bottomView.frame.origin.y = self.view.frame.height - self.bottomViewHeight
            }
        } else {
            self.bottomView.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.bottomView.frame.origin.y = .screenHeight
            }
        }
    }
}

public extension SheetModalPresentable where Self: UIViewController {
    /// bottom close view height
    var bottomViewHeight: CGFloat {
        72 + CGFloat.footerHeight
    }
    /// fast enbale bottom close view
    var bottomView: BottomView {
        let key  = UnsafeRawPointer.init(bitPattern: "pan_bottom_close_key".hashValue)!
        if let bar = objc_getAssociatedObject(self, key) as? BottomView {
            return bar
        }
        let bar = BottomView()
        bar.isHidden = !enableBottomView
        bar.clickCloseClosure = { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        objc_setAssociatedObject(self, key, bar, .OBJC_ASSOCIATION_RETAIN)
        self.view.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: bottomViewHeight).isActive = true
        return bar
    }
}
