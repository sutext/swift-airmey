//
//  WidgetsController.swift
//  Example
//
//  Created by supertext on 6/15/21.
//

import UIKit
import Airmey

class WidgetsController: UIViewController {
    let contentView = AMEffectView(.light)
    let stackView = UIStackView()
    let digitLabel  = AMDigitLabel()
    let testView = AMImageView()
    let timer = AMTimer()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Widgets", image: .round(.blue, radius: 10), selectedImage: .round(.red, radius: 10))
    }
    deinit{
        timer.stop()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(testView)
        self.view.addSubview(contentView)
        self.view.addSubview(digitLabel)
        self.contentView.addSubview(self.stackView)
        self.contentView.am.edge.equal(to: 0)
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .equalCentering
        self.stackView.spacing = 20
        self.stackView.am.center.equal(to: 0)
        self.testView.backgroundColor = .red
        self.timer.delegate = self
        digitLabel.textColor = .black
        digitLabel.digit = 0
        digitLabel.formater = {
            String(format: "$%.2f", Float($0)/100)
        }
        self.testView.amake { am in
            am.centerX.equal(to: 0)
            am.top.equal(to: 80)
            am.size.equal(to: 200)
        }
        digitLabel.amake { am in
            am.edge.equal(to: view, insets: 100)
        }
        self.addTest("swiper") {[weak self] in
            self?.navigationController?.pushViewController(SwiperController(), animated: true)
        }
        self.addTest("digitLabel") {
            self.digitLabel.remake { am in
                am.centerX.equal(to: 0)
                am.top.equal(to: 150)
            }
        }
        self.addTest("start Timer") {
            self.timer.start()
        }
        self.addTest("pause timer") {
            self.timer.pause()
        }
        self.addTest("stop timer") {
            self.timer.stop()
        }
    }
    func addTest(_ text:String,action:(()->Void)?) {
        let imageLabel = AMImageLabel(.left)
        imageLabel.image = .rect(.red, size: CGSize(width: 20, height: 20), radius: 5, border: (.blue,2))
        imageLabel.text = text
        imageLabel.font = .systemFont(ofSize: 17)
        imageLabel.textColor = .black
        self.stackView.addArrangedSubview(imageLabel)
        imageLabel.onclick = {_ in
            action?()
        }
    }
}
extension WidgetsController:AMTimerDelegate{
    func timer(_ timer: AMTimer, repeated times: Int) {
        if times > 5 {
            timer.stop()
        }
        DispatchQueue.main.async {
            self.navbar.title = "times :\(times)"
        }
    }
}
