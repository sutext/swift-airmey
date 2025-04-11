//
//  CardFlipViewController.swift
//  Example
//
//  Created by chao on 2023/4/6.
//

import UIKit
import Airmey
import MapKit

class CardFlipViewController: AMPopupController {
    init(initView: UIView?) {
        let present = CardFlipPresenter(initView: initView)
        super.init(present)
        present.flipView = mapView
        present.bottomView = bottomView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(mapView)
        view.addSubview(bottomView)
        mapView.amake { make in
            make.top.equal(to: 0.0)
            make.left.equal(to: 0.0)
            make.right.equal(to: 0.0)
            make.bottom.equal(to: bottomView.am.top)
        }
        bottomView.amake { make in
            make.left.equal(to: 0.0)
            make.bottom.equal(to: 0.0)
            make.right.equal(to: 0.0)
            make.height.equal(to: 100.0)
        }
        bottomView.addSubview(label)
        label.amake { make in
            make.center.equal(to: 0.0)
        }
        view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pop.dismiss(self)
    }
    
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.layer.cornerRadius = 20.0
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30.0)
        label.text = "Card Flip"
        return label
    }()
}
