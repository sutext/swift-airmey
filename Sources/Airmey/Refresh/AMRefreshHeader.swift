//  Airmey
//  AMRefreshHeader.swift
//
//  Created by supertext on 2020/8/14.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit

/// Builtin Refresh Header
open class AMRefreshHeader: AMRefresh {
    ///用于兼容下拉加载更多
    public var noMoreData: Bool = true
    ///下拉完成，是否还原原有inset
    public var enableReductionInset: Bool = true
    public let loading:Loading
    public init(_ indicator:Loading = Loading(),height:CGFloat?=nil) {
        self.loading = indicator
        super.init(.header,height: height)
        self.addSubview(indicator)
        indicator.am.center.equal(to: 0)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override var isEnabled: Bool{
        didSet{
            self.loading.isHidden = !isEnabled
        }
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.amake { am in
                am.top.equal(to: -self.height)
                am.centerX.equal(to: 0)
            }
        }
    }
    public override func statusChanged(_ status: AMRefresh.Status,old:Status){
        loading.update(status: status)
        if case .refreshing = status {
            var insets = self.originalInset
            insets.top = self.height+insets.top
            UIView.animate(withDuration: 0.25) {
                self.scorllView?.contentOffset = CGPoint(x: 0, y: -self.height)
                self.scorllView?.contentInset = insets
            }
        }else{
            func reductionInset() {
                UIView.animate(withDuration: 0.25) {
                    self.scorllView?.contentInset = self.originalInset
                }
            }
            if enableReductionInset {
                reductionInset()
            } else {
                if noMoreData {
                    reductionInset()
                }
            }
        }
    }
    
    public override func contentOffsetChanged() {
        guard let scview = self.scorllView else {
            return
        }
        let offset = scview.contentOffset.y
        let happenOffset = -self.originalInset.top
        if offset > happenOffset {
            return
        }
        var percent = (happenOffset - offset)/self.height
        percent = (percent <> CGFloat(0)...CGFloat(1))
        if scview.isDragging {
            loading.update(percent: percent)
            if self.status == .idle , percent >= 1 {
                self.status = .draging
            }else if self.status == .draging && percent < 1{
                self.status = .idle
            }
        }else if self.status == .draging{
            self.beginRefreshing()
        }
    }
    public override func contentSizeChanged() {
        
    }
    public override func gestureStateChanged() {
        
    }
}

extension AMRefresh{
    open class Loading:UIView{
        private lazy var activity:UIActivityIndicatorView = {
            let view = UIActivityIndicatorView(style: .medium)
            view.hidesWhenStopped = false
            self.addSubview(view)
            view.am.edge.equal(to: 0)
            return view
        }()
        open func update(status: AMRefresh.Status) {
            switch status {
            case .idle:
                activity.stopAnimating()
            case .refreshing:
                activity.startAnimating()
            default:
                break
            }
        }
        open func update(percent: CGFloat) {
            activity.transform = CGAffineTransform(rotationAngle: -percent * .pi)
        }
        public static func gif(_ images:[UIImage],duration:TimeInterval? = nil)->Loading{
            GifLoading(images,duration: duration)
        }
        public static func image(_ image: UIImage,duration:TimeInterval? = nil)->Loading{
            ImageLoading(image,duration: duration)
        }
        public static func imageText(_ image: UIImage,
                                     style: AMRefresh.Style = .footer,
                                     duration:TimeInterval? = nil,
                                     texts:[AMRefresh.Status:AMTextDisplayable] = [:],
                                     fonts:[AMRefresh.Status:UIFont] = [:],
                                     colors:[AMRefresh.Status:UIColor] = [:])->Loading{
            let loading = ImageTextLoading(image,
                                           duration: duration,
                                           texts: texts,
                                           fonts: fonts,
                                           colors: colors)
            loading.am.size.equal(to: (CGFloat.screenWidth, style.defaultHeight))
            return loading
        }
    }
}
extension AMRefresh{
    public class GifLoading:Loading{
        private let inner = UIImageView()
        private let images:[UIImage]
        private let duration:TimeInterval
        public init(_ images:[UIImage] ,duration:TimeInterval? = nil) {
            guard images.count>1 else {
                fatalError("image count must gather than 1")
            }
            self.images = images
            if let dur = duration {
                self.duration = dur
            }else{
                self.duration = Double(images.count) * 0.1
            }
            super.init(frame:.zero)
            self.addSubview(inner)
            inner.image = images.last
            inner.am.edge.equal(to: 0)
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        public override func update(status: AMRefresh.Status) {
            switch status {
            case .idle:
                inner.stopAnimating()
            case .refreshing:
                inner.animationImages = images
                inner.animationDuration = duration
                inner.startAnimating()
            default:
                break
            }
        }
        public override func update(percent: CGFloat) {
            let index = Int(CGFloat(images.count - 1)*percent)
            inner.image = images[index]
        }
    }
    
    public class ImageLoading:Loading{
        private let inner = UIImageView()
        private var duration:TimeInterval = 1
        private lazy var rotateAnimation: CABasicAnimation = {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.toValue = Double.pi * 2
            rotateAnimation.repeatCount = MAXFLOAT
            return rotateAnimation
        }()
        public init(_ image: UIImage ,duration:TimeInterval? = nil) {
            super.init(frame:.zero)
            self.addSubview(inner)
            inner.image = image
            inner.am.edge.equal(to: 0)
            if let dur = duration {
                self.duration = dur
            }
            self.rotateAnimation.duration = self.duration
        }
        
        private func innerStartAnimating() {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 1)
            inner.layer.add(rotateAnimation, forKey: nil)
        }
        
        private func innerStopAnimating() {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 1)
            inner.layer.removeAllAnimations()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        public override func update(status: AMRefresh.Status) {
            switch status {
            case .idle:
                innerStopAnimating()
            case .refreshing:
                innerStartAnimating()
            default:
                break
            }
        }
        public override func update(percent: CGFloat) {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, .pi*percent*2, 0, 0, 1)
        }
    }
}

extension AMRefresh{
    
    public class ImageTextLoading:Loading{
        private let inner = UIImageView()
        private var duration:TimeInterval = 1
        private let innerText = UILabel()
        private var texts:[Status:AMTextDisplayable]?
        private var fonts:[Status:UIFont]?
        private var colors:[Status:UIColor]?
        private lazy var rotateAnimation: CABasicAnimation = {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.toValue = Double.pi * 2
            rotateAnimation.repeatCount = MAXFLOAT
            return rotateAnimation
        }()
        public init(_ image: UIImage,
                    duration:TimeInterval? = nil,
                    texts:[Status:AMTextDisplayable]?,
                    fonts:[Status:UIFont]?,
                    colors:[Status:UIColor]?) {
            super.init(frame:.zero)
            self.addSubview(inner)
            inner.image = image
            inner.am.center.equal(to: 0)
            inner.am.size.equal(to: (image.size.width, image.size.height))
            if let dur = duration {
                self.duration = dur
            }
            self.rotateAnimation.duration = self.duration
            self.addSubview(innerText)
            
            innerText.isHidden = true
            innerText.textAlignment = .center
            innerText.am.edge.equal(to: 0)
            
            self.texts = texts
            self.fonts = fonts
            self.colors = colors
        }
        
        private func innerStartAnimating() {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 1)
            inner.layer.add(rotateAnimation, forKey: nil)
            innerText.isHidden = true
            inner.isHidden = false
        }
        
        private func innerStopAnimating() {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 1)
            inner.layer.removeAllAnimations()
            innerText.isHidden = true
            inner.isHidden = false
        }
        
        private func nomoreDataStatus() {
            innerStopAnimating()
            innerText.isHidden = false
            inner.isHidden = true
            innerText.text = self.texts?[.nomore]?.text ?? ""
            innerText.font = self.fonts?[.nomore] ?? .systemFont(ofSize: 14)
            innerText.textColor = self.colors?[.nomore] ?? .gray
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        public override func update(status: AMRefresh.Status) {
            switch status {
            case .idle:
                innerStopAnimating()
            case .refreshing:
                innerStartAnimating()
            case .nomore:
                nomoreDataStatus()
            default:
                break
            }
        }
        public override func update(percent: CGFloat) {
            inner.layer.transform = CATransform3DRotate(CATransform3DIdentity, .pi*percent*2, 0, 0, 1)
        }
    }
}
