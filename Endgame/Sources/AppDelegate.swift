//
//  AppDelegate.swift
//  Endgame
//
//  Created by Todd Olsen on 8/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var app: App?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let window = window {
            app = App(window: window)
        }
        return true
    }

}

final class App {

    // This is implicitly unwrapped because
    var navigationController: UINavigationController!

    init(window: UIWindow) {

        let configuration = TableViewConfiguration(
            items: games,
            style: .plain,
            nibName: "GameCell",
            reusableCellClass: GameCell.self,
            configureCell: configureGameCell,
            didSelect: showGame,
            didTapConfigure: showConfiguration
        )

        self.navigationController = UINavigationController(rootViewController: TableViewController(configuration: configuration))
        window.rootViewController = navigationController
    }

    let games: Array<Game> = {

        let files: [String] = [
            "fischer v fine",
            "shirov v judit_polgar",
            "nakamura v fluvia_poyatos"
        ]

        return files
            .map { Bundle(for: App.self).url(forResource: $0, withExtension: "pgn")! }
            .map { try! String(contentsOf: $0) }
            .map { try! PGN(parse: $0) }
            .map(Game.init)
    }()

    func configureGameCell(cell: UITableViewCell, game: Game) -> () {
        let white = game.whitePlayer.name ?? "?"
        let black = game.blackPlayer.name ?? "?"
        cell.textLabel?.text = "\(white) vs. \(black)"
        cell.imageView?.image = UIImage(view: game.board.view(edge: cell.bounds.height))
    }

    func showGame(game: Game) {
        guard let gameViewController = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "Game") as? GameViewController else {
            fatalError("Could not find GameViewController Storyboard.")
        }
        gameViewController.game = game
        navigationController.pushViewController(gameViewController, animated: true)
    }

    func showConfiguration() {

    }

}
