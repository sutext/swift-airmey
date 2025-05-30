//
//  AppDelegate.swift
//  Example
//
//  Created by supertext on 5/27/21.
//

import UIKit
import Airmey

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AMPopupCenter.initializePopupSettings()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = RootViewController()
        self.window?.makeKeyAndVisible()
        return true
    }
}

