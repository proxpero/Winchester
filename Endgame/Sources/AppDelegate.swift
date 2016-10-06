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
    var configuration: MenuConfiguration?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let window = window else { return false }
        configuration = MenuConfiguration(window: window)
        return true
    }

}

final class Configuration {

    let navigationController: UINavigationController
    let profile: Profile

    init(window: UIWindow, profile: Profile) {
        self.profile = profile
        self.navigationController = window.rootViewController as! UINavigationController

    }

    enum Section: Int {
        case newGame
        case recentGames
        case favoriteGames
        case puzzles
        case settings

        var all: [Section] {
            return [.newGame, .recentGames, .favoriteGames, .puzzles, .settings]
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        var title: String {
            switch self {
            case .newGame: return "New Game"
            case .recentGames: return "Recent Games"
            case .favoriteGames: return "Favorite Games"
            case .puzzles: return "Puzzles"
            case .settings: return "Settings"
            }
        }
    }

    

}

final class App {

    // This is implicitly unwrapped because some functions needed
    // to initialize it are in `self`, and they cannont both be
    // initialized first.
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
        cell.imageView?.image = UIImage(view: game.currentPosition.thumbnail(edge: cell.bounds.height))
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
