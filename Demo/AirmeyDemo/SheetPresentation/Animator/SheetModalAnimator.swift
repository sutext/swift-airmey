//
//  SheetModalAnimator.swift
//
//
//  Created by yongjun chen on 2023/2/20.
//

import UIKit

/**
 动画类
 */
struct SheetModalAnimator {

    struct Constants {
        static let defaultTransitionDuration: TimeInterval = 0.25
    }

    static func animate(_ animations: @escaping SheetModalPresentable.AnimationBlockType,
                        config: SheetModalPresentable?,
                        _ completion: SheetModalPresentable.AnimationCompletionType? = nil) {

        let transitionDuration = config?.transitionDuration ?? Constants.defaultTransitionDuration
        let springDamping = config?.springDamping ?? 1.0
        let animationOptions = config?.transitionAnimationOptions ?? []

        UIView.animate(withDuration: transitionDuration,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations: animations,
                       completion: completion)
    }
}
