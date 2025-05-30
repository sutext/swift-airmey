//
//  CCNavBar.swift
//  Global
//
//  Created by supertext on 5/26/21.
//  Copyright © 2021 clipclaps. All rights reserved.
//

import UIKit
import Airmey

public class CCNavBar: AMToolBar {
    public override class var style: Style{.header}
    public override init() {
        super.init()
        self.usingEffect()
        self.usingShadow()
        self.backgroundColor = .hex(0xeeeeee, alpha: 0.4)
    }
    /// navgation title
    public var title:String?{
        didSet{
            self.titleLabel.text = title
            self.titleItem = self.titleLabel
        }
    }
    /// navgation titleView
    public var titleItem:UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            if let newval = titleItem {
                self.contentView.addSubview(newval)
                newval.am.center.equal(to: 0)
            }
        }
    }
    public var leftItems:[Item]?{
        didSet{
            if oldValue != nil {
                leftStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
            if let newval = leftItems {
                newval.forEach{leftStack.addArrangedSubview($0.content)}
            }
        }
    }
    public var rightItems:[Item]?{
        didSet{
            if oldValue != nil {
                rightStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
            if let newval = rightItems {
                newval.forEach{rightStack.addArrangedSubview($0.content)}
            }
        }
    }
    public func setAction(_ type:ItemType,at index:Int,action:ONClick?){
        let stack = type == .left ? leftStack : rightStack
        guard index < stack.arrangedSubviews.count else {
            return
        }
        let view = stack.arrangedSubviews[index]
        switch view {
        case let v as AMView:
            v.onclick = action
        case let b as AMButton:
            b.onclick = action
        default:
            break
        }
    }
    private lazy var leftStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .equalSpacing
        self.contentView.addSubview(stack)
        stack.amake { am in
            am.left.equal(to: 15)
            am.centerY.equal(to: 0)
        }
        return stack
    }()
    private lazy var rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .equalSpacing
        self.contentView.addSubview(stack)
        stack.amake { am in
            am.right.equal(to: -15)
            am.centerY.equal(to: 0)
        }
        return stack
    }()
    private lazy var titleLabel:AMLabel = {
        let label = AMLabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
}
extension CCNavBar{
    public var titleFont:UIFont?{
        get{ self.titleLabel.font }
        set{ self.titleLabel.font = newValue }
    }
    public var titleColor:UIColor?{
        get{ self.titleLabel.textColor }
        set{ self.titleLabel.textColor = newValue }
    }
    public var leftSpacing:CGFloat{
        get{ self.leftStack.spacing }
        set{ self.leftStack.spacing = newValue }
    }
    public var rightSpacing:CGFloat{
        get{ self.rightStack.spacing }
        set{ self.rightStack.spacing = newValue }
    }
}
extension CCNavBar{
    public enum ItemType{
        case left
        case right
    }
    public enum Item{
        case custom(UIView)
        fileprivate var content:UIView{
            switch self {
            case .custom(let v):
                return v
            }
        }
    }
}
fileprivate var navbarKey:Void?
extension UIViewController{
    public var navbar:CCNavBar{
        if let bar = objc_getAssociatedObject(self, &navbarKey) as? CCNavBar{
            return bar
        }
        let bar = CCNavBar()
        self.view.addSubview(bar)
        objc_setAssociatedObject(self, &navbarKey, bar, .OBJC_ASSOCIATION_RETAIN)
        return bar
    }
}

