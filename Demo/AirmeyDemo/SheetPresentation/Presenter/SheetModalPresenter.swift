//
//  sheetModalPresenter.swift
//  sheetModal
//
//  Copyright © 2019 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/**
 A protocol for objects that will present a view controller as a sheetModal

 - Usage:
 ```
 viewController.presentSheetModal(viewControllerToPresent: presentingVC,
                                             sourceView: presentingVC.view,
                                             sourceRect: .zero)
 ```
 */
public protocol SheetModalPresenter: AnyObject {

    /**
     A flag that returns true if the current presented view controller
     is using the sheetModalPresentationDelegate
     */
    var issheetModalPresented: Bool { get }

    /**
     Presents a view controller that conforms to the sheetModalPresentable protocol
     */
    func presentSheetModal(_ viewControllerToPresent: SheetModalPresentable.LayoutType,
                         sourceView: UIView?,
                         sourceRect: CGRect,
                         completion: (() -> Void)?)

}
#endif
