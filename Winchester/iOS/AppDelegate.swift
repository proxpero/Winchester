//
//  AppDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 8/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame
import Shared

public protocol CloudObserver: class {
    func storeDidChange(with notification: Notification)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let window = window else { return false }
        let appCoordinator = ApplicationCoordinator(window: window)
        registerCloud(for: appCoordinator)
        
        return true
    }

    func registerCloud(for observer: CloudObserver) {
//        NotificationCenter.default.addObserver(observer,
//                                               selector: #selector(storeDidChange),
//                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
//                                               object: NSUbiquitousKeyValueStore.default)
    }

//    func storeDidChange(with notification: Notification) {
//        print("\(notification.object)")
//    }

}
