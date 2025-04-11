//
//  File.swift
//
//
//  Created by yongjun chen on 2022/6/29.
//

import UIKit

/// 手势穿透视图
open class GesturePenetrationView: UIView {
    /// 是否需要穿透，默认为true
    public var isPenetration = true
    
    /// 穿透事件时，自身可以响应事件回调
    public var eventBlock: (() -> Void)?

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !isPenetration {
            return super.point(inside: point, with: event)
        }
        for subView in subviews.reversed() {
            let convertedPoint = subView.convert(point, from: self)
            if !subView.isHidden, subView.alpha > 0.01, subView.isUserInteractionEnabled, subView.point(inside: convertedPoint, with: event) {
                return true
            }
        }
        
        if super.point(inside: point, with: event) {
            eventBlock?()
        }
        return false
    }
}
