//
//  TestViewController.swift
//  Example
//
//  Created by cyy on 2023/10/11.
//

import Foundation
import UIKit
import Airmey

class TestPenetrationViewController: UIViewController, SheetModalPresentable {
    public var close: Bool = false
    
    /// 重载loadView，主要为了替换VC默认的视图
    override public final func loadView() {
        view = GesturePenetrationView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .purple
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        btn.setTitle("XXXX", for: .normal)
        btn.frame = .init(x: 150, y: 200, width: 50, height: 50)
        view.addSubview(btn)
    }
    
    @objc func clickAction() {
        print("1111....")
        if self.close {
            self.dismiss(animated: true)
        }
        let vc = TestPenetrationViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.close = true
        
        self.present(vc, animated: true)
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: SheetModalHeight {
        return .maxHeightWithTopInset(200.0)
    }
    
    var longFormHeight: SheetModalHeight {
        return .contentHeight(.screenHeight)
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(#function):\(self)")
    }
    
    override var defaultPopupConfig: AMPopupConfig { .init(shouldUseNewWindow: true, allowsPenetration: true)}
}
