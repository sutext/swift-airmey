//
//  AMPopupController.swift
//  Airmey
//
//  Created by supertext on 2021/5/30.
//

import UIKit

/// Describe the popup level base on UIWindow.Level
public typealias AMPopupLevel = UIWindow.Level

extension AMPopupLevel{
    /// Just for set window level friendly
    ///
    ///         let window = UIWindow()
    ///         window.windowLevel = .alert + 1
    ///
    public static func +(lhs:AMPopupLevel,rhs:CGFloat)->UIWindow.Level{
        return AMPopupLevel(rawValue: lhs.rawValue + rhs)
    }
    public static func -(lhs:AMPopupLevel,rhs:CGFloat)->UIWindow.Level{
        return AMPopupLevel(rawValue: lhs.rawValue - rhs)
    }
    /// global default wait window level
    /// by default use .alert + 2000
    public static var wait:AMPopupLevel { .alert + 2000 }
    /// global default remind window level
    /// by default use .alert + 1000
    public static var remind:AMPopupLevel { .alert + 1000 }
    /// global default remind window level
    /// by default use .alert
    public static var action:AMPopupLevel { .alert }
}
fileprivate var popKey:Void?
fileprivate var popWindowKey:Void?
fileprivate var popPenetrationKey:Void?
fileprivate var allowsClearKey:Void?
fileprivate var popupConfigKey:Void?
/// Configuration class for AMPopup settings.
@objc public class AMPopupConfig: NSObject {
    
    /// Priority level of the popup. Determines the display order relative to other popups.
    public var popupLevel: AMPopupLevel
    
    /// Determines if the popup can be automatically cleared from the screen.
    public var isClearAllowed: Bool
    
    /// Indicates whether the popup should use a new window for display.
    public var shouldUseNewWindow: Bool
    
    /// Determines if the popup window allows user interaction to pass through to the underlying content.
    public var allowsPenetration: Bool
    
    /// Indicates if the view is a controller popped up by `AMPopupCenter`.
    public var isPopup: Bool = false
        
    /// Initializes the AMPopupConfig with optional custom settings.
    /// - Parameters:
    ///   - popupLevel: The display priority level of the popup. Default is `.normal`.
    ///   - isClearAllowed: Indicates if the popup can be cleared. Default is `true`.
    ///   - shouldUseNewWindow: Determines if a new window should be used for displaying the popup. Default is `false`.
    ///   - allowsPenetration: Specifies if user interactions can pass through the popup. Default is `false`.
    public init(
        popupLevel: AMPopupLevel = .normal,
        isClearAllowed: Bool = true,
        shouldUseNewWindow: Bool = false,
        allowsPenetration: Bool = false
    ) {
        self.popupLevel = popupLevel
        self.isClearAllowed = isClearAllowed
        self.shouldUseNewWindow = shouldUseNewWindow
        self.allowsPenetration = allowsPenetration
    }
}

extension UIViewController{
    /// Returns the popupConfig for the instance.
    /// If the popupConfig is not set, it returns the defaultPopupConfig.
    public var popupConfig: AMPopupConfig {
        get {
            // If a custom popupConfig is set, return it.
            if let config = objc_getAssociatedObject(self, &popupConfigKey) as? AMPopupConfig {
                return config
            }
            let defaultConfig = self.defaultPopupConfig
            self.popupConfig = defaultConfig
            // Otherwise, return the default popupConfig.
            return defaultConfig
        }
        set {
            // Set the custom popupConfig for this instance.
            objc_setAssociatedObject(self, &popupConfigKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Default popupConfig that can be customized as needed.
    /// If the instance does not have a custom popupConfig, this default config is used.
    @objc open var defaultPopupConfig: AMPopupConfig {
        return AMPopupConfig()
    }
    
    /// Custom dismiss function that handles dismissal of view controllers with popups in AMPopupCenter.
    /// If the view controller is associated with a popup configuration, it dismisses the popup and manages the operation queue.
    ///
    /// - Parameters:
    ///   - flag: A Boolean value that indicates whether the dismissal should be animated.
    ///   - completion: An optional completion block to be executed after the dismissal is completed.
    @objc private func builtinDismiss(animated flag: Bool, completion: AMBlock? = nil) {
        let pop = AMPopupCenter.default
        // If the view controller is not presenting any other view controller and it was presented via popcenter, dismiss it using AMPopupCenter
        if self.presentedViewController == nil, popupConfig.isPopup {
            pop.dismiss(self, animated: flag, completion: completion)
            return
        }
        // Call the original dismiss function with animation and completion
        self.builtinDismiss(animated: flag, completion: completion)
    }
    public func _dismiss(animated flag: Bool, completion: AMBlock? = nil) {
        self.builtinDismiss(animated: flag, completion: nil)
        let window = self.view.window as? AMWindowable
        func hideWindow(){
            let pop = AMPopupCenter.default
            if popupConfig.shouldUseNewWindow == true,
               let wind = window,
               let idx = pop.windows.lastIndex(where: { $0 == wind }) {
                wind.resignKey()
                wind.isHidden = true
                pop.windows.remove(at: idx)
            }
            if let lastWindow = pop.windows.last {
                lastWindow.makeKey()
            }
        }
        /// make callback surely
        if flag {
            let duration = ((self as? AMPopupController)?.presenter.transitionDuration ?? 0.30) + 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                hideWindow()
                completion?()
            }
        } else {
            hideWindow()
            completion?()
        }
    }
    class public func swizzleDismiss() {
        let originalSelector = #selector(UIViewController.dismiss(animated:completion:))
        let swizzledSelector = #selector(UIViewController.builtinDismiss(animated:completion:))
        let aClass = UIViewController.self
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)!
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
open class AMPopupController:UIViewController{
    /// public presenter
    public let presenter:AMPresenter
    ///
    /// AMPopupController designed initializer
    /// - Parameters:
    ///     - presenter: The present animation describer
    /// - Note: After init  A default implements of presenter.onMaskClick will be set.
    ///
    public init(_ presenter:AMPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = presenter
        self.modalPresentationStyle = .custom
        presenter.onMaskClick = {[weak self] in
            self?.dismiss(animated: true)
        }
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override var shouldAutorotate: Bool { presenter.shouldAutorotate }
    
    open override var defaultPopupConfig: AMPopupConfig { .init(shouldUseNewWindow: true) }
}

public typealias AMAlertBlock = (Int)->Void
public typealias AMActionBlock = (AMTextDisplayable?,Int?)->Void
public typealias AMAlertTextFieldBlock = (UITextField) -> Void

///Loading style
public protocol AMWaitable:AMPopupController{
    static var timeout:TimeInterval {get}
    init(_ msg:String?,timeout:TimeInterval?)
}
///Tost style
public protocol AMRemindable:AMPopupController{
    init(_ msg:AMTextDisplayable,title:AMTextDisplayable?,inset: UIEdgeInsets?, position: RemindPosition?)
}
///Alert style
public protocol AMAlertable:UIViewController{
    init(
        _ msg:AMTextDisplayable,
        title:AMTextDisplayable?,
        confirm:AMTextDisplayable?,
        cancel:AMTextDisplayable?,
        textFieldBlock: AMAlertTextFieldBlock?,
        buttonsAxis: NSLayoutConstraint.Axis,
        onhide:AMAlertBlock?)
}
///ActionSheet style
public protocol AMActionable:UIViewController{
    init(_ items:[AMTextDisplayable],onhide:AMActionBlock?)
}
/// Alert window
public protocol AMWindowable:UIWindow{
    var isPenetration: Bool { get set }
    /// modal controller
    var presentViewController: UIViewController? { get }
    /// Previous present controller
    var previousViewController: UIViewController? { get }
    init(_ previousViewController: UIViewController?)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
extension AMWindowable {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {}
}

public enum RemindPosition {
    case middle
    case bottom
}
