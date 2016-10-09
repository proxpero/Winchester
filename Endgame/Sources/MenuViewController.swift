//
//  MenuViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/24/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

final class MenuConfiguration {

    let navigationController: UINavigationController

    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    init(window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController
        let menuViewController = self.navigationController.viewControllers[0] as! MenuViewController
        menuViewController.recentGamesConfiguration = RecentGamesConfiguration(navigationViewController: navigationController)
    }

}

struct Profile {
    let name: String
}

struct Settings {
    
}

final class MenuViewController: UITableViewController {

    enum Section: Int {
        case newGame
        case recentGames
        case favoriteGames
        case puzzles
        case settings

        static var all: [Section] {
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
            case .newGame: return ""
            case .recentGames: return "Recent Games"
            case .favoriteGames: return "Favorite Games"
            case .puzzles: return "Puzzles"
            case .settings: return "Settings"
            }
        }
    }

    var recentGamesConfiguration: RecentGamesConfiguration?
    var favoriteGames: [Game] = []
    var didSelectFavoriteGame: (Game) -> () = { _ in }
    var didSelectShowAllFavoriteGames: () -> () = { }
    var puzzles: [EPD] = []
    var didSelectPuzzle: (EPD) -> () = { _ in }
    var didSelectShowAllPuzzles: () -> () = { _ in }
    var didSelectProfile: (Profile) -> () = { _ in }
    var didSelectSettings: (Settings) -> () = { _ in }

}

extension MenuViewController {

    override func viewDidLoad() {
        tableView.register(NewGameCell.self, forCellReuseIdentifier: NewGameCell.reuseIdentifier)
        tableView.register(RecentGameCell.self, forCellReuseIdentifier: RecentGameCell.reuseIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .newGame: return 1
        case .recentGames:
            guard let recentGamesConfiguration = recentGamesConfiguration else { return 0 }
            return recentGamesConfiguration.recentGames.count + 1
        case .favoriteGames: return 0
        case .puzzles: return 0
        case .settings: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(section).title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(at: indexPath)
        switch section {
        case .newGame:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewGameCell.reuseIdentifier, for: indexPath) as! NewGameCell
            configureNewGameCell(cell, at: indexPath)
            return cell
        case .recentGames:
            let cell = tableView.dequeueReusableCell(withIdentifier: RecentGameCell.reuseIdentifier, for: indexPath) as! RecentGameCell
            if let recent = recentGamesConfiguration {
                recent.configure(cell: cell, at: indexPath)
            }
            return cell
        default:
            return UITableViewCell()
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(at: indexPath)
        switch section {
        case .newGame: didSelectNewGame()
        case .recentGames: recentGamesConfiguration?.didSelect(at: indexPath)
        default:
            break
        }
    }

    func didSelectNewGame() {
        print(#function)
    }

    func configureNewGameCell(_ cell: NewGameCell, at indexPath: IndexPath) {
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "New Game"
    }
}

class NewGameCell: UITableViewCell {
    static var reuseIdentifier = "\(NewGameCell.self)"
}

