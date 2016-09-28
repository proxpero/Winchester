//
//  RecentGamesConfiguration.swift
//  Endgame
//
//  Created by Todd Olsen on 9/26/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import UIKit
import Engine

struct RecentGamesConfiguration {

    let navigationViewController: UINavigationController

    init(navigationViewController: UINavigationController) {
        self.navigationViewController = navigationViewController
    }

    let recentGames: [Game] = [
            "fischer v fine",
//            "karpov v kasparov",
            "shirov v judit_polgar"
        ].map { resource in
            let url = Bundle(for: AppDelegate.self).url(forResource: resource, withExtension: "pgn")!
            let text = try! String.init(contentsOf: url)
            let pgn = try! PGN(parse: text)
            return Game(pgn: pgn)
        }

    func didSelect(at indexPath: IndexPath) {
        if indexPath.row == recentGames.count {
            showAll()
            return
        }

        let game = recentGames[indexPath.row]
        print(game.pgn)
        guard let gameViewController = UIStoryboard(name: "Game", bundle: nil).instantiateInitialViewController() as? GameViewController else { fatalError("Could not create GameViewController\n\(#function)") }
        gameViewController.game = game
        navigationViewController.pushViewController(gameViewController, animated: true)
    }

    func showAll() {
        print(#function)
    }

    func configure(cell: RecentGameCell, at indexPath: IndexPath) {
        print(indexPath)
        if indexPath.row == recentGames.count {
            cell.textLabel?.text = "Show All"
        } else {
            let game = recentGames[indexPath.row]
            let white = game.whitePlayer.name ?? "?"
            let black = game.blackPlayer.name ?? "?"
            let outcome = game.outcome.description
            cell.textLabel?.text = "\(white) \(outcome) \(black)"
        }
    }



}

class RecentGameCell: UITableViewCell {
    static var reuseIdentifier = "\(RecentGameCell.self)"
}
