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
        coordinator = ApplicationCoordinator(window: window)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeDidChange(with:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default())
        return true
    }

    func storeDidChange(with notification: Notification) {
        print("Store did change")
        guard let store = notification.object as? NSUbiquitousKeyValueStore else { fatalError("Did not return ubiquitous store.") }
        func games(in key: String) -> Dictionary<String, Game> {
            var games = Dictionary<String, Game>()
            guard let dict = store.dictionary(forKey: key) as? Dictionary<String, String> else { fatalError("") }
            for (key, value) in dict {
                let pgn = try! PGN(parse: value) // FIXME: try!
                let game = Game(pgn: pgn)
                games[key] = game
            }
            return games
        }
        guard let games = store.array(forKey: "games") as? [Dictionary<String, Game>] else { return }
    }
}
