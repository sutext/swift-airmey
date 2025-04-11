//
//  sheetModalPresentable+LayoutHelpers.swift
//  sheetModal
//
//  Copyright © 2018 Tiny Speck, Inc. All rights reserved.
//

import UIKit

/**
 Helper extensions that handle layout in the sheetModalPresentationController
 */
extension SheetModalPresentable where Self: UIViewController {

    /**
     Cast the presentation controller to sheetModalPresentationController
     so we can access sheetModalPresentationController properties and methods
     */
    var presentedVC: SheetModalPresentationController? {
        return presentationController as? SheetModalPresentationController
    }

    /**
     Returns the short form Y position

     - Note: If voiceover is on, the `longFormYPos` is returned.
     We do not support short form when voiceover is on as it would make it difficult for user to navigate.
     */
    var shortFormYPos: CGFloat {

        guard !UIAccessibility.isVoiceOverRunning
            else { return longFormYPos }

        let shortFormYPos = topMargin(from: shortFormHeight) + topOffset

        // shortForm shouldn't exceed longForm
        return max(shortFormYPos, longFormYPos)
    }

    /**
     Returns the long form Y position

     - Note: We cap this value to the max possible height
     to ensure content is not rendered outside of the view bounds
     */
    var longFormYPos: CGFloat {
        return max(topMargin(from: longFormHeight), topMargin(from: .maxHeight)) + topOffset
    }

    /**
     Use the container view for relative positioning as this view's frame
     is adjusted in sheetModalPresentationController
     */
    var bottomYPos: CGFloat {

        guard let container = presentedVC?.containerView
            else { return view.bounds.height }

        return container.bounds.size.height - topOffset
    }

    /**
     Converts a given pan modal height value into a y position value
     calculated from top of view
     */
    func topMargin(from: SheetModalHeight) -> CGFloat {
        switch from {
        case .maxHeight:
            return 0.0
        case .maxHeightWithTopInset(let inset):
            return inset
        case .contentHeight(let height):
            return bottomYPos - height
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize = CGSize(width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                                    height: UIView.layoutFittingCompressedSize.height)
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            return bottomYPos - intrinsicHeight
        }
    }
}
