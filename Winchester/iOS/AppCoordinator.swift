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

//    private let _userGames = Dictionary<String, Game>()
//    private let _classicGames = Dictionary<String, Game>()

    fileprivate let navigationController: UINavigationController
    fileprivate let gameCollectionViewController: GameCollectionViewController

    // MARK: - Initializers

    init(window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController
        self.gameCollectionViewController = UIStoryboard.game.instantiate(GameCollectionViewController.self)
        navigationController.addChildViewController(gameCollectionViewController)
    }

    func start() {
        gameCollectionViewController.collectionView?.reloadData()
    }

    func storeDidChange(with notification: Notification) {

        guard let store = notification.object as? NSUbiquitousKeyValueStore else { fatalError("Did not return ubiquitous store.") }
        func games(in key: String) -> GameCollection {
            var games = GameCollection()
            guard let dict = store.dictionary(forKey: key) as? Dictionary<String, String> else { fatalError("") }
            for (key, value) in dict {
                let pgn = try! PGN(parse: value) // FIXME: try!
                let game = Game(pgn: pgn)
                games[key] = game
            }
            return games
        }
        let userGames = games(in: "user-games")
        let classicGames = games(in: "classic-games")
        sections = [
            GameCollectionViewController.Section(title: "My Games", items: userGames.map { GameCollectionViewController.Item.game(game: $0.value)  }),
            GameCollectionViewController.Section(title: "Classic Games", items: classicGames.map { GameCollectionViewController.Item.game(game: $0.value)  })
        ]
        gameCollectionViewController.collectionView?.reloadData()
    }
    
//    func start() {
//        _presentRootCollectionView()
//    }
//    
//    // MARK: -
//
//    private func _presentRootCollectionView() {
//
//        let vc = gameCollectionViewController
//
//        // MARK: Delegate
//
//        func _presentUserGame(game: Game) {
//            game.undoAll()
//            var coordinator = GameCoordinator(for: game, isUserGame: true)
//            let vc = coordinator.loadViewController()
//            navigationController.pushViewController(vc, animated: true)
//        }
//
//        func _presentFavoriteGame(game: Game) {
//            game.undoAll()
//            var coordinator = GameCoordinator(for: game)
//            let vc = coordinator.loadViewController()
//            navigationController.pushViewController(vc, animated: true)
//        }
//
//    }

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

