//
//  AppDelegate.swift
//  GameViewDemo
//
//  Created by Todd Olsen on 9/28/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import UIKit
import Engine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var configuration: Configuration?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        configuration = Configuration(window: window)
        return true
    }

}

final class Configuration {

    let navigationController: UINavigationController
    let games: [Game] = {
        var games = [
            "fischer v fine",
            "shirov v judit_polgar",
            "test case 1",
            "test case 2",
            "test case 3",
            "test case 4",
            "test case 5"
            ]
            .flatMap { Bundle(for: AppDelegate.self).url(forResource: $0, withExtension: "pgn") }
            .map { try! String(contentsOf: $0) }
            .map { try! PGN(parse: $0) }
            .flatMap { Game(pgn: $0) }
        games.forEach { $0.move(to: $0.startIndex) }
        return games
    }()

    init(window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController
        let tableViewController = self.navigationController.viewControllers[0] as! TableViewController
        tableViewController.games = games
        tableViewController.didSelect = show
    }

    let gameStoryboard = UIStoryboard(name: "Game", bundle: nil)

    func show(game: Game) {
        let gameViewController = gameStoryboard.instantiateInitialViewController() as! GameViewController
        gameViewController.game = game
        navigationController.pushViewController(gameViewController, animated: true)
    }
}

class TableViewController: UITableViewController {
    var games: [Game] = []
    var didSelect: (Game) -> () = { _ in }
}

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(games[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let game = games[indexPath.row]
        cell.textLabel?.text = "\(game.whitePlayer.name!) \(game.outcome.description) \(game.blackPlayer.name!)"
        return cell
    }
}

