//
//  sheetModalPresentable+UIViewController.swift
//  sheetModal
//
//  Copyright © 2018 Tiny Speck, Inc. All rights reserved.
//

import UIKit

/**
 Extends sheetModalPresentable with helper methods
 when the conforming object is a UIViewController
 */
public extension SheetModalPresentable where Self: UIViewController {

    typealias AnimationBlockType = () -> Void
    typealias AnimationCompletionType = (Bool) -> Void

    /**
     For Presentation, the object must be a UIViewController & confrom to the sheetModalPresentable protocol.
     */
    typealias LayoutType = UIViewController & SheetModalPresentable

    /**
     A function wrapper over the `transition(to state: sheetModalPresentationController.PresentationState)`
     function in the sheetModalPresentationController.
     */
    func sheetModalTransition(to state: SheetModalPresentationController.PresentationState) {
        presentedVC?.transition(to: state)
    }

    /**
     A function wrapper over the `setNeedsLayoutUpdate()`
     function in the sheetModalPresentationController.

     - Note: This should be called whenever any of the values for the sheetModalPresentable protocol are changed.
     */
    func sheetModalSetNeedsLayoutUpdate() {
        presentedVC?.setNeedsLayoutUpdate()
    }

    /**
     Operations on the scroll view, such as content height changes, or when inserting/deleting rows can cause the pan modal to jump,
     caused by the pan modal responding to content offset changes.

     To avoid this, you can call this method to perform scroll view updates, with scroll observation temporarily disabled.
     */
    func sheetModalPerformUpdates(_ updates: () -> Void) {
        presentedVC?.performUpdates(updates)
    }

    /**
     A function wrapper over the animate function in sheetModalAnimator.

     This can be used for animation consistency on views within the presented view controller.
     */
    func sheetModalAnimate(_ animationBlock: @escaping AnimationBlockType, _ completion: AnimationCompletionType? = nil) {
        SheetModalAnimator.animate(animationBlock, config: self, completion)
    }

}
