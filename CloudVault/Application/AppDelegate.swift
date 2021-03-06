//
//  AppDelegate.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 28.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import UIKit
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var authSubscription: AnyCancellable?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        self.authSubscription = Authenticator.shared.status.sink {
//            print("Auth value => \($0)")
//        }
//
//        Authenticator.shared.authenticateWithBiometrics()
        sysInitialization()
        return true
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillResignActive(_ application: UIApplication) { AppSystem.shared.releaseResources() }

    func sysInitialization() {
        _ = AppSystem.shared
        _ = AppSettings.shared
        _ = AppRepository.shared
    }
    
}

