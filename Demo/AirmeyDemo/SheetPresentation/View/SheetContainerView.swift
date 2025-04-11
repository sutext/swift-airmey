//
//  PanContainerView.swift
//  sheetModal
//
//  Copyright © 2018 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/**
 A view wrapper around the presented view in a sheetModal transition.

 This allows us to make modifications to the presented view without
 having to do those changes directly on the view
 */
class SheetContainerView: UIView {

    init(presentedView: UIView, frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentedView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("\(#function):\(self)")
        let offY = point.y + SheetModalPresentationController.Constants.dragIndicatorSize.height + SheetModalPresentationController.Constants.indicatorYOffset
        let point = CGPoint(x: point.x, y: offY)
        return super.point(inside: point, with: event)
    }
}

extension UIView {

    /**
     Convenience property for retrieving a PanContainerView instance
     from the view hierachy
     */
    var panContainerView: SheetContainerView? {
        return subviews.first(where: { view -> Bool in
            view is SheetContainerView
        }) as? SheetContainerView
    }

}
#endif
