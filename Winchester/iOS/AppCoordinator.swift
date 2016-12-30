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

class ApplicationCoordinator: GameCollectionViewControllerDataSource {

    var sections: [GameCollectionViewController.Section] = []

    // MARK: - Private Stored Properties

    fileprivate let navigationController: UINavigationController
    fileprivate let gameCollectionViewController: GameCollectionViewController

    // MARK: - Initializers

    init(window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController
        self.gameCollectionViewController = UIStoryboard.game.instantiate(GameCollectionViewController.self)
    }

    func start() {

        guard let sharedDefaults = UserDefaults(suiteName: "group.com.proxpero.winchester.shared") else {
            return
        }

        let opponents = sharedDefaults.dictionary(forKey: "opponents") as? Dictionary<String, Dictionary<String, String>> ??  Dictionary<String, Dictionary<String, String>>()

        sections = opponents.map { (player, dict) in
            let games = dict.flatMap { (id, string) in
                guard let url = URL(string: string), let game = Game(with: url) else { return nil }
                    return game
                }
                .map { GameCollectionViewController.Item.game(game: $0) }
            return GameCollectionViewController.Section(title: player, items: games)
        }

        gameCollectionViewController.dataSource = self
        gameCollectionViewController.delegate = self
        gameCollectionViewController.collectionView?.reloadData()

        navigationController.pushViewController(gameCollectionViewController, animated: true)
        gameCollectionViewController.navigationItem.backBarButtonItem = UIBarButtonItem()
//        var navItem = gameCollectionViewController.navigationItem
//        let backButton = UIBarButtonItem(title: "Games", style: .plain, target: self, action: #selector(backAction))
//        navItem.backBarButtonItem = UIBarButtonItem()

    }

    @objc func backAction() {

    }

}

extension ApplicationCoordinator: GameCollectionViewControllerDelegate {

    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController) {

        let game = Game()
        var coordinator = GameCoordinator(for: game, isUserGame: true)
        let vc = coordinator.loadViewController()
        navigationController.pushViewController(vc, animated: true)

    }

    func gameCollectionViewControllerDidSelectShowMore(_ controller: GameCollectionViewController, for section: GameCollectionViewController.Section) {

    }

    func gameCollectionViewController(_ controller: GameCollectionViewController, didSelect game: Game) {
        var coordinator = GameCoordinator(for: game, isUserGame: true)
        let vc = coordinator.loadViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    func gameCollectionViewController(_ controller: GameCollectionViewController, shouldShowSection: GameCollectionViewController.Section) -> Bool {
        return true
    }

}

