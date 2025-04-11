//
//  File.swift
//
//
//  Created by yongjun chen on 2022/12/7.
//

import Foundation

public extension DispatchQueue {
    static var `default`: DispatchQueue { return DispatchQueue.global(qos: .default) }
    static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive) }
    static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
    static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility) }
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }

    private static var _onceTracker = [String]()
    class func once(_ token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }

    func after(_ delay: TimeInterval, execute: @escaping (() -> Void)) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }

    @discardableResult
    func delayWorkItem(_ delay: TimeInterval, execute: (() -> Void)?) -> DispatchWorkItem {
        let delayItem = DispatchWorkItem { execute?() }
        asyncAfter(deadline: .now() + delay, execute: delayItem)
        return delayItem
    }

    static var isMainQueue: Bool {
        enum Static {
            static var key: DispatchSpecificKey<Void> = {
                let key = DispatchSpecificKey<Void>()
                DispatchQueue.main.setSpecific(key: key, value: ())
                return key
            }()
        }
        return DispatchQueue.getSpecific(key: Static.key) != nil
    }
}
