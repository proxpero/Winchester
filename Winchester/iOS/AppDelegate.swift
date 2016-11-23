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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let window = window else { return false }
        coordinator = ApplicationCoordinator(
            window: window
        )
        coordinator?.start()
        return true
    }

}
