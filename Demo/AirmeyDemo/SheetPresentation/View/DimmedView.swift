//
//  DimmedView.swift
//  sheetModal
//
//  Copyright © 2017 Tiny Speck, Inc. All rights reserved.
//

import UIKit
//import UTKit

/**
 A dim view for use as an overlay over content you want dimmed.
 */
public class DimmedView: UIView {

    /**
     Represents the possible states of the dimmed view.
     max, off or a percentage of dimAlpha.
     */
    enum DimState {
        case max
        case off
        case percent(CGFloat)
    }

    // MARK: - Properties

    /**
     The state of the dimmed view
     */
    var dimState: DimState = .off {
        didSet {
            switch dimState {
            case .max:
                alpha = 1.0
            case .off:
                alpha = 0.0
            case .percent(let percentage):
                alpha = max(0.0, min(1.0, percentage))
            }
        }
    }
    
    var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }
    
    var enablePopOverBackground: Bool = false {
        didSet {
            popOverBackgroundView.isHidden = !enablePopOverBackground
        }
    }

    /**
     The closure to be executed when a tap occurs
     */
    var didTap: ((_ recognizer: UIGestureRecognizer) -> Void)?

    /**
     Tap gesture recognizer
     */
    private lazy var tapGesture: UIGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapView))
    }()
    
    private lazy var popOverBackgroundView: UIView = {
        let popOver = UIView()
        popOver.isHidden = enablePopOverBackground
        return popOver
    }()

    // MARK: - Initializers

    init(dimColor: UIColor = UIColor.black.withAlphaComponent(0.7)) {
        super.init(frame: .zero)
        alpha = 0.0
        backgroundColor = dimColor
        addGestureRecognizer(tapGesture)
        
        addSubview(backgroundImageView)
        layer.addSublayer(backgroundColorLayer)
        
        addSubview(popOverBackgroundView)
        popOverBackgroundView.isHidden = true /// 默认隐藏
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds
        backgroundColorLayer.frame = bounds
        popOverBackgroundView.frame = bounds
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            backgroundColorLayer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    public func starPopOverAnitaion() {
//        popOverBackgroundView.startAnimation()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private lazy var backgroundImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var backgroundColorLayer: CALayer = {
        let v = CALayer()
        return v
    }()

    // MARK: - Event Handlers

    @objc private func didTapView() {
        didTap?(tapGesture)
    }
}
