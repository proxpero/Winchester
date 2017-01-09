//
//  AppCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame
import Shared
import Shared_iOS

final class GameCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

final class OpponentCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AppCoordinator {

    let navigationController: UINavigationController

    init(window: UIWindow) {

        self.navigationController = window.rootViewController as! UINavigationController

        let opponents = OpponentStore.defaultStore.opponents.map { $0.value }

        let opponentsVC = ItemsViewController(items: opponents, configure: { (cell: OpponentCell, opponent) in
            cell.textLabel?.text = opponent.name
        })

        navigationController.setViewControllers([opponentsVC], animated: false)

        opponentsVC.didSelect = { opponent in
            let games = opponent.games
    
            let gamesVC = ItemsViewController(items: games, configure: self.configure)

            gamesVC.title = opponent.name
            gamesVC.didSelect = { game in
                var coordinator = GameCoordinator(for: game, isUserGame: false)
                let vc = coordinator.loadViewController()
                self.navigationController.pushViewController(vc, animated: true)
            }
            self.navigationController.pushViewController(gamesVC, animated: true)
        }

        opponentsVC.title = "Opponents"

    }

    func configure(gameCell: GameCell, with game: Game) {
        gameCell.textLabel?.text = game.whitePlayer.name
    }

}
