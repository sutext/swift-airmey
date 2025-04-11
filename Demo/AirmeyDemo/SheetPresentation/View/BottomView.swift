//
//  BottomView.swift
//
//  Created by yongjun chen on 2023/2/17.
//

import UIKit
import Airmey

public class BottomView: GesturePenetrationView {
    // MARK: - properties
    
    public var clickCloseClosure: (() -> Void)?
    
    /// 禁用背景图
    public var disableBackgroundImage: Bool = false {
        didSet {
            bgImageView.isHidden = disableBackgroundImage
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupSubViews()
        setupLayouts()
        registerEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SubViews
    func setupSubViews() {
        backgroundColor = .clear
        addSubview(bgImageView)
        addSubview(closeButton)
    }
    
    // MARK: - Layout
    func setupLayouts() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        bgImageView.am.edge.equal(to: 0)
    }
    
    // MARK: handle event
    func registerEvent() {
        
    }
    
    private lazy var bgImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
//        v.image = UIImage.named("modal_sheet_bottom_bg")
        v.isHidden = disableBackgroundImage
        return v
    }()
    
    // MARK: lazy loads
   public lazy var closeButton: UIButton = {
        let b = UIButton(type: .custom)
//        b.setImage(UIImage.named("sheet_modal_bottom_close"), for: .normal)
        b.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        return b
    }()
}

extension BottomView {
    @objc
    func clickCloseAction(_ sender: UIButton) {
        clickCloseClosure?()
    }
}

