//
//  AppDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 8/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let window = window else { return false }
        coordinator = ApplicationCoordinator(
            window: window,
            model: ApplicationCoordinator.Model(
                updateUserGames: updateUserGames,
                updateFavoriteGames: updateFavoriteGames
            )
        )
        coordinator?.start()
        return true
    }

    let files = ["fischer v fine", "reti v rubenstein", "shirov v polgar"]

    func updateUserGames() -> [Game] {
        return files
            .flatMap { Bundle.main.url(forResource: $0, withExtension: "pgn") }
            .map { try! String(contentsOf: $0) }
            .map { try! PGN(parse: $0) }
            .map { Game(pgn: $0) }
    }

    func updateFavoriteGames() -> [Game] {
        return files
            .flatMap { Bundle.main.url(forResource: $0, withExtension: "pgn") }
            .map { try! String(contentsOf: $0) }
            .map { try! PGN(parse: $0) }
            .map { Game(pgn: $0) }
    }
}
