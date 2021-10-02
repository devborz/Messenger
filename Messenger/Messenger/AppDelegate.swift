//
//  AppDelegate.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        if DatabaseManager.shared.currentUserID == nil {

            let vc = UINavigationController(rootViewController: LoginViewController())
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        } else {
            let vc = TabBarController()
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }


}

