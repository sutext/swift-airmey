//
//  File.swift
//  
//
//  Created by yongjun chen on 2023/2/20.
//

import UIKit

class IndicatorView: UIView {
    // MARK: - properties
    
    override init(frame: CGRect) {
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
        addSubview(indicatorView)
    }
    
    // MARK: - Layout
    func setupLayouts() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    // MARK: handle event
    func registerEvent() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.setCorners([.topLeft, .topRight], radius: 20)
    }
    
    // MARK: lazy loads
    private lazy var indicatorView: UIView = {
        let v = UIView()
        return v
    }()
}




