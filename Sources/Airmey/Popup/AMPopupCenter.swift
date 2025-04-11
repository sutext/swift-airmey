//
//  AMPopup.swift
//  Airmey
//
//  Created by supertext on 5/28/21.
//

import UIKit
///Add an  popup operation queue
final public class AMPopupCenter {
    public static var `default`: AMPopupCenter = .init()
    /// default Wait controller  override it for custom
    public static var Wait:AMWaitable.Type = AMWaitController.self
    /// default Alert controller  override it for custom. By defualt use system Impl
    public static var Alert:AMAlertable.Type = UIAlert.self
    /// default Remind controller  override it for custom
    public static var Remind:AMRemindable.Type = AMRemindController.self
    /// default Action controller  override it for custom By defualt use system Impl
    public static var Action:AMActionable.Type = UIAlert.self
    
    public static var Window:AMWindowable.Type = AMPopupWindow.self
    /// All use the new window present controller
    public internal(set) var windows:[AMWindowable] = []
    private var queue:[Operation] = []
    private var current:Operation?
    private var alerters:[String:Alerter] = [:]
    private weak var waiter:UIViewController?
    private init(){
        UIViewController.swizzleDismiss()
    }
}
extension AMPopupCenter{
    /// dismiss any UIViewController
    public func dismiss(
        _ vc:UIViewController,
        animated:Bool=true,
        completion:AMBlock?=nil){
            self.add(.dismiss(vc: vc, animated: animated, finish: completion))
        }
    /// present any UIViewController
    /// Any  AMPopupController instance will be present in AMPopupWindow otherwise using delegate window
    public func present(
        _ vc:UIViewController,
        animated:Bool=true,
        config: AMPopupConfig?=nil,
        completion:AMBlock?=nil){
            if let config { vc.popupConfig = config }
            vc.popupConfig.isPopup = true
            self.add(.present(vc: vc, animated: animated, finish: completion))
        }
    /// presnet a remindable controller
    public func remind(
        _ msg:AMTextDisplayable,
        title:AMTextDisplayable?=nil,
        duration:TimeInterval?=nil,
        meta:AMRemindable.Type?=nil,
        messageInset: UIEdgeInsets?=nil,
        position: RemindPosition?=nil,
        config: AMPopupConfig?=nil,
        onhide:AMBlock?=nil) {
            let vc = (meta ?? Self.Remind).init(msg, title: title, inset: messageInset, position: position)
            if let config { vc.popupConfig = config }
            vc.popupConfig.isPopup = true
            self.add(.remind(vc,duration:duration))
        }
    /// presnet an actionable controller
    ///
    ///- Parameters:
    ///     - items: The actionsheet itmes
    ///     - meta: The actionsheet implemention class
    ///
    public func action(
        _ items:[AMTextDisplayable],
        meta:AMActionable.Type?=nil,
        config: AMPopupConfig?=nil,
        onhide:AMActionBlock?=nil){
            let vc = (meta ?? Self.Action).init(items,onhide:onhide)
            if let config { vc.popupConfig = config }
            vc.popupConfig.isPopup = true
            self.add(.action(vc))
        }
    /// present an alertable controller
    ///
    ///- Note: Same msg alert never been present together
    ///
    ///- Parameters:
    ///     - msg: The alert message must be provide.
    ///     - title: The alert title
    ///     - confirm: The confirm text. If nil use `Confirm`
    ///     - cancel: The cancel text. if nil no Cancel option
    ///     - meta: The alert implemention. if ni use defualt
    ///     - onhide: The call back when click
    ///
    @discardableResult
    public func alert(
        _ msg:AMTextDisplayable,
        title:AMTextDisplayable? = nil,
        confirm:AMTextDisplayable? = nil,
        cancel:AMTextDisplayable? = nil,
        meta:AMAlertable.Type? = nil,
        textFieldBlock: AMAlertTextFieldBlock? = nil,
        buttonsAxis: NSLayoutConstraint.Axis = .horizontal,
        config: AMPopupConfig?=nil,
        onhide:AMAlertBlock? = nil) -> AMAlertable? {
            if let key = msg.text {
                let vc = (meta ?? Self.Alert).init(msg, title: title,confirm: confirm,cancel: cancel, textFieldBlock: textFieldBlock, buttonsAxis: buttonsAxis, onhide: onhide)
                if let config { vc.popupConfig = config }
                vc.popupConfig.isPopup = true
                self.add(.alert(vc,key:key))
                return vc
            }
            return nil
        }
    /// present a waitable controller
    ///
    ///- Parameters:
    ///     - msg: The wating message
    ///     - timeout: The wating timeout
    ///     - meta: The wating implemention
    ///
    public func wait(
        _ msg:String? = nil,
        timeout:TimeInterval?=nil,
        config: AMPopupConfig?=nil,
        meta:AMWaitable.Type?=nil){
        let vc = (meta ?? Self.Wait).init(msg,timeout:timeout)
        if let config { vc.popupConfig = config }
        vc.popupConfig.isPopup = true
        self.add(.wait(vc))
    }
    /// dismiss current wating controller
    public func idle() {
        self.add(.idle)
    }
    /// Clear all the presented  controller
    public func clear() {
        self.add(.clear)
    }
    /// current top controller from the key window
    public var top:UIViewController?{
        var next:UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while next?.presentedViewController != nil {
            next = next?.presentedViewController
        }
        return next
    }
}
extension AMPopupCenter{
    private func add(_ op:Operation) {
        DispatchQueue.main.async {
            self.queue.append(op)
            self.next()
        }        
    }
    private func delayNext(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.next()
        }
    }
    private func next() {
        guard self.current == nil,
              !self.queue.isEmpty else {
            return
        }
        self.current = self.queue.removeFirst()
        guard let current = self.current else {
            return
        }
        switch current {
        case .wait(let vc):
            self._wait(vc)
        case .idle:
            self._idle()
        case .clear:
            self._clear()
        case .remind(let vc,let duration):
            self._remind(vc,duration: duration)
        case .alert(let vc,let key):
            self._alert(vc, key: key,animated: true, finish: nil)
        case .action(let vc):
            self._present(vc, animated: true, finish: nil)
        case .present(let vc, let animated,let finish):
            self._present(vc,animated: animated,finish: finish)
        case .dismiss(let popup,let animated,let finish):
            self._dismiss(popup,animated:animated,finish: finish)
        }
    }
    private func _clear() {
        let windowsToClear = self.windows.filter { $0.presentViewController?.popupConfig.isClearAllowed ?? false }
        self.windows.removeAll(where: { $0.presentViewController?.popupConfig.isClearAllowed ?? false })
        windowsToClear.forEach {
            $0.rootViewController = nil
            $0.isHidden = true
        }
        self.current = nil
        self.delayNext()
    }
    private func _dismiss(_ vc:UIViewController, animated:Bool,finish:AMBlock?){
        let block = {
            finish?()
            self.current = nil
            self.delayNext()
        }
        vc._dismiss(animated: animated,completion: block)
    }
    private func _alert(_ vc:UIViewController,key:String,animated:Bool,finish:AMBlock?) {
        self.alerters = self.alerters.filter({ ele in
            return ele.value.controller != nil
        })
        if self.alerters[key] != nil{
            self.current = nil
            self.delayNext()
            return
        }
        self.alerters[key] = Alerter(vc)
        self.show(vc,animated: animated) {
            finish?()
            self.current = nil
            self.delayNext()
        }
    }
    private func _present(_ vc:UIViewController,animated:Bool,finish:AMBlock?) {
        self.show(vc,animated: animated) {
            finish?()
            self.current = nil
            self.delayNext()
        }
    }
    private func _remind(_ vc:UIViewController,duration:TimeInterval?) {
        self.show(vc)
        DispatchQueue.main.asyncAfter(deadline: .now()+(duration ?? 1)) {
            vc._dismiss(animated: true){
                self.current = nil
                self.delayNext()
            }
        }
    }
    private func _wait(_ vc:UIViewController)  {
        guard self.waiter == nil else {
            self.current = nil
            self.delayNext()
            return
        }
        self.waiter = vc
        self.show(vc) {
            self.current = nil
            self.delayNext()
        }
    }
    private func _idle() {
        guard let vc = self.waiter else {
            self.current = nil
            self.delayNext()
            return
        }
        vc._dismiss(animated: true){
            self.waiter = nil
            self.current = nil
            self.delayNext()
        }
    }
    private func show(_ vc: UIViewController,animated: Bool=true, completion: AMBlock? = nil){
        if vc.popupConfig.shouldUseNewWindow {
            let window = Self.Window.init(top)
            window.isPenetration = vc.popupConfig.allowsPenetration
            self.windows.append(window)
            window.makeKeyAndVisible()
            window.present(vc, animated: animated, completion: nil)
        }else {
            self.top?.present(vc, animated: animated, completion: nil)
        }
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                completion?()
            }
        }else{
            completion?()
        }
    }
}
extension AMPopupCenter{
    enum Operation{
        case idle
        case clear
        case wait(_ vc:UIViewController)
        case alert(_ vc:UIViewController,key:String)
        case action(_ vc:UIViewController)
        case remind(_ vc:UIViewController,duration:TimeInterval?)
        case present(
                vc:UIViewController,
                animated:Bool,
                finish:AMBlock?)
        case dismiss(
                vc:UIViewController,
                animated:Bool,
                finish:AMBlock?)
    }
    class Alerter:NSObject {
        weak var controller:UIViewController?
        init(_ vc:UIViewController) {
            self.controller = vc
        }
    }
}
extension AMPopupCenter{
    /// system implemention for AMAlertable AMActionable
    open class UIAlert:UIAlertController,AMAlertable,AMActionable{
        public required convenience init(
            _ msg: AMTextDisplayable,
            title: AMTextDisplayable?,
            confirm: AMTextDisplayable?,
            cancel: AMTextDisplayable?,
            textFieldBlock: AMAlertTextFieldBlock?,
            buttonsAxis: NSLayoutConstraint.Axis,
            onhide: AMAlertBlock?) {
            self.init(
                title: title?.text,
                message: msg.text,
                preferredStyle: .alert)
            self.addAction(.init(title: confirm?.text ?? "Confirm", style: .default, handler: { act in
                onhide?(0)
            }))
            if let cancel = cancel {
                self.addAction(.init(title: cancel.text, style: .default, handler: { act in
                    onhide?(1)
                }))
            }
        }
        public required convenience init(_ items: [AMTextDisplayable], onhide: AMActionBlock?) {
            self.init(title: nil, message: nil, preferredStyle: .actionSheet)
            for idx in (0..<items.count) {
                self.addAction(.init(title: items[idx].text, style: .default, handler: { act in
                    onhide?(items[idx],idx)
                }))
            }
            self.addAction(.init(title: "Cancel", style: .destructive, handler: { act in
                onhide?(nil,nil)
            }))
        }
    }
}

open class AMPopupWindow:UIWindow,AMWindowable{
    public var isPenetration: Bool = false
    
    /// modal controller
    public private(set) weak var presentViewController: UIViewController?
    /// Previous present controller
    public private(set) weak var previousViewController: UIViewController?
    required public init(_ previousViewController: UIViewController? = nil) {
        super.init(frame: UIScreen.main.bounds)
        self.windowLevel = .alert
        self.backgroundColor = .clear
        self.rootViewController = UIViewController(nibName: nil, bundle: nil)
        self.rootViewController?.view.backgroundColor = .clear
        self.previousViewController = previousViewController
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.presentViewController = viewControllerToPresent
        self.windowLevel = viewControllerToPresent.popupConfig.popupLevel
        self.rootViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
