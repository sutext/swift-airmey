//
//  PopupTestController.swift
//  Example
//
//  Created by supertext on 2021/5/30.
//

import UIKit
import Airmey
let pop = AMPopupCenter.default

enum LoginError:Error {
    case invalidPassword
    case invalidUsername
}
extension LoginError:AMTextDisplayable{
    var displayText: AMDisplayText{
        switch self {
        case .invalidPassword:
            return "Invalid Password"
        case .invalidUsername:
            return "Invalid username"
        }
    }
}

public class UTPopupWindow: AMPopupWindow {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isPenetration,
              let rootViewController,
              let presentedViewController = rootViewController.presentedViewController else {
            return super.point(inside: point, with: event)
        }
        let sheetMoodalVC = findSheetModalController(presentedViewController)
        if let presentationController = sheetMoodalVC?.presentationController,
           let targetView = presentationController.presentedView,
           presentationController as? SheetModalPresentationController != nil {
            let convertedPoint = targetView.convert(point, from: self)
            return targetView.point(inside: convertedPoint, with: event)
        }
        return super.point(inside: point, with: event)
    }
    
    private func findSheetModalController(_ viewController: UIViewController) -> UIViewController? {
        if let vc = viewController.presentedViewController {
            return findSheetModalController(vc)
        }
        return viewController
    }
}
extension AMPopupCenter {
    public static func initializePopupSettings() {
        AMPopupCenter.Alert = AMAlertController.self
        AMPopupCenter.Action = AMActionController.self
        AMPopupCenter.Window = UTPopupWindow.self
    }
}

extension AMPopupCenter {
    public func presentSheetModal(_ viewControllerToPresent: SheetModalPresentable.LayoutType,
                                  shouldUseNewWindow: Bool=true,
                                  animated: Bool=true,
                                  completion: AMBlock? = nil) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
        viewControllerToPresent.transitioningDelegate = SheetModalPresentationDelegate.default
        viewControllerToPresent.popupConfig.shouldUseNewWindow = shouldUseNewWindow
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

class PopupController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.tabBarItem = UITabBarItem(title: "Popup", image: .round(.yellow, radius: 10), selectedImage: .round(.cyan, radius: 10))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let stackView = UIStackView()
    let scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.backgroundColor = .white
        self.scrollView.contentInsetAdjustmentBehavior = .never
        navbar.title = "Popup Tester"
        self.scrollView.contentInset = UIEdgeInsets(top: .navbarHeight, left: 0, bottom: .tabbarHeight, right: 0)
        self.scrollView.am.edge.equal(to: 0)
        let images = (1...45).compactMap {
            UIImage(named: String(format: "loading%02i", $0), in: .main, compatibleWith: nil)
        }
        self.scrollView.using(refresh: AMRefreshHeader(.gif(images)))
        self.scrollView.addSubview(self.stackView)
        self.scrollView.delegate = self
        self.stackView.backgroundColor = .white
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 20
        self.stackView.amake { am in
            am.center.equal(to: 0)
            am.edge.equal(top: 0, bottom: 0)
        }
        self.addTest("Test multiple popup") {
            pop.wait("loading....")
            pop.idle()
            pop.remind("testing....")
            pop.alert("test alert",confirm: "OK",cancel: "cancel")
            pop.alert("test 2",confirm: "OK",cancel: "cancel")
            pop.alert("test 1",confirm: "OK",cancel: "cancel")
            pop.remind("test1")
            pop.action(["facebook","apple"])
            pop.alert("clear all",confirm: "OK",cancel: "cancel", onhide:  { idx in
                if idx == 0 {
                    pop.clear()
                }
            })
            pop.remind("testing....")
            pop.alert("test alert",confirm: "OK",cancel: "cancelcancel")
            pop.remind(LoginError.invalidUsername)
        }
        self.addTest("Test Input") {
            pop.present(PopupInputController())
        }
        self.addTest("clear") {
            pop.clear()
        }
        self.addTest("Gesture penetration controller") {
            let vc = TestPenetrationViewController()
            pop.presentSheetModal(vc)
        }
        self.addTest("Test Wait") {
            pop.wait("loading...")
        }
        self.addTest("Test remind") {
            pop.remind("test remind")
            
            pop.remind("test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1test1test1test1test1test1testest1test1test1test1test1test1test1test1test1test1tes")
            pop.remind("test remind")
        }
        
        let label = AMLabel(frame: CGRect(x: 100.0,
                                          y: .screenHeight - 250.0,
                                          width: 100.0,
                                          height: 140.0))
        label.onclick = { _ in
            let vc = CardFlipViewController(initView: nil)
            pop.present(vc)
        }
        label.backgroundColor = .orange
        label.text = "Default"
        label.font = .systemFont(ofSize: 30.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 20.0
        label.layer.masksToBounds = true
        view.addSubview(label)
        
        let label2 = AMLabel(frame: CGRect(x: 210.0,
                                          y: .screenHeight - 250.0,
                                          width: 100.0,
                                          height: 140.0))
        label2.onclick = { view in
            let vc = CardFlipViewController(initView: view)
            pop.present(vc)
        }
        label2.backgroundColor = .orange
        label2.text = "Flip"
        label2.font = .systemFont(ofSize: 30.0)
        label2.textAlignment = .center
        label2.layer.cornerRadius = 20.0
        label2.layer.masksToBounds = true
        view.addSubview(label2)
    }
    func addTest(_ text:String,action:(()->Void)?) {
        let imageLabel = AMImageLabel(.left)
        imageLabel.image = .round(.red, radius: 5)
        imageLabel.text = text
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.stackView.addArrangedSubview(imageLabel)
        imageLabel.onclick = {_ in
            action?()
        }
    }
}

extension PopupController:AMScrollViewDelegate{
    func scrollView(_ scrollView: UIScrollView, willBegin refresh: AMRefresh) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            refresh.endRefreshing()
        }
    }
}
