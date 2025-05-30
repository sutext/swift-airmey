//
//  RootViewController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey

var root:RootViewController? = nil
class RootViewController: AMLayoutViewContrller {
    let tabbarController:UITabBarController = UITabBarController()
    init() {
        super.init(rootViewController: tabbarController)
        self.leftDisplayMode = .background
        root = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let popup = UINavigationController(rootViewController: PopupController())
        let widget = UINavigationController(rootViewController: WidgetsController())
        popup.setNavigationBarHidden(true, animated: false)
        widget.setNavigationBarHidden(true, animated: false)
        self.tabbarController.viewControllers = [popup,widget]
        self.tabbarController.selectedIndex = 1
        self.leftViewController = PopupController()
    }
    func push(_ controller:UIViewController)  {
        self.dismissCurrentController(animated: false)
        if let nav = self.tabbarController.selectedViewController as? UINavigationController {
            nav.pushViewController(controller, animated: true)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        [.landscapeRight,.portrait]
    }
    override var shouldAutorotate: Bool { true } 
}
