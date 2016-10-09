//
//  AppDelegate.swift
//  NewGameDemo
//
//  Created by Todd Olsen on 10/7/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import UIKit
import Engine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var configuration: Configuration?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        guard let window = window else { return }
        configuration = Configuration(window)

    }

}

let myGamesKey = "my-games"

final class Configuration {

    enum Section: Int {
        case newGame
        case myGames

        static var all: [Section] {
            return [.newGame, .myGames]
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        var title: String {
            switch self {
            case .newGame: return ""
            case .myGames: return "My Games"
            }
        }
    }

    let navigationController: UINavigationController

    init(_ window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController
        let vc = self.navigationController.viewControllers[0] as! TableViewController
        vc.sectionCount = sectionCount
        vc.headerTitle = headerTitle
        vc.rowCount = rowCount
        vc.didSelect = didSelect
        vc.cellIdentifier = cellIdentifier
        vc.configure = configure
        vc.update = {
            self.save()
        }
    }

    private var temp: Game?

    private let _gameStoryboard = UIStoryboard(name: "Game", bundle: nil)

    func sectionCount() -> Int {
        return Section.all.count
    }

    func headerTitle(for section: Int) -> String {
        return Section(section).title
    }

    func rowCount(for section: Int) -> Int {
        switch Section(section) {
        case .newGame: return 1
        case .myGames: return games.count
        }
    }

    func didSelect(indexPath: IndexPath) {
        switch Section(at: indexPath) {
        case .newGame:
            didSelectNewGame()
        case .myGames:
            let game = games[indexPath.row]
            didSelect(game)
        }
    }

    func cellIdentifier(for indexPath: IndexPath) -> String {
        return "Cell"
    }

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        switch Section(at: indexPath) {
        case .newGame: cell.textLabel?.text = "New Game"
        case .myGames:
            let game = games[indexPath.row]
            cell.textLabel?.text = "\(game.whitePlayer.name) vs \(game.blackPlayer.name)"
        }
    }

    func didSelectNewGame() {
        let gameViewController = _gameStoryboard.instantiateInitialViewController() as! GameViewController
        gameViewController.game = Game()
        gameViewController.isEditable = true
        gameViewController.save = { game in
            self.temp = game
        }
        navigationController.pushViewController(gameViewController, animated: true)
    }

    func didSelect(_ game: Game) {
        let gameViewController = _gameStoryboard.instantiateInitialViewController() as! GameViewController
        gameViewController.game = game
        navigationController.pushViewController(gameViewController, animated: true)
    }

    func save() {
        guard let temp = temp else { return }
        var pgns = UserDefaults.standard.array(forKey: myGamesKey) as? [String] ?? [String]()
        let pgn = temp.pgn.exported()
        pgns.append(pgn)
        UserDefaults.standard.set(pgns, forKey: myGamesKey)
    }

    var games: [Game] {
        let removePgns = false
        if removePgns {
            UserDefaults.standard.set([], forKey: myGamesKey)
        }
        let pgns = UserDefaults.standard.array(forKey: myGamesKey) as? [String] ?? [String]()
        let games = pgns
            .map { try! PGN(parse: $0) }
            .flatMap { Game(pgn: $0) }
        games.forEach { $0.move(to: $0.startIndex) }
        return games
    }
}

class TableViewController: UITableViewController {
    var sectionCount: () -> Int = { _ in 0 }
    var headerTitle: (Int) -> String = { _ in "" }
    var rowCount: (Int) -> (Int) = { _ in 0 }
    var didSelect: (IndexPath) -> () = { _ in }
    var cellIdentifier: (IndexPath) -> String = { _ in "" }
    var configure: (UITableViewCell, IndexPath) -> () = { _ in }
    var update: () -> () = { }
}

extension TableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle(section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount(section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(indexPath), for: indexPath)
        configure(cell, indexPath)
        return cell
    }
}
