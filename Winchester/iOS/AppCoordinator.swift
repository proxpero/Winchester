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

struct ApplicationCoordinator {

    // MARK: - Private Stored Properties

    private let _navigationController: UINavigationController
//    private let _model: AppDataSource

    // MARK: - Initializers

    init(window: UIWindow) {
        self._navigationController = window.rootViewController as! UINavigationController
//        self._model = model
        start()
    }

    func start() {
        _presentRootCollectionView()
    }

    // MARK: -
    
    private func _presentRootCollectionView() {

        guard let vc = _navigationController.viewControllers[0] as? RootCollectionViewController else { fatalError("Could not create RootCollectionViewController") }

        // MARK: Model

        vc.model = RootCollectionViewController.Model(
            userGames: userGames(),
            classicGames: classicGames()
        )

        // MARK: Delegate

        func _presentUserGame(game: Game) {
            game.undoAll()
            var coordinator = GameCoordinator(for: game, isUserGame: true)
            let vc = coordinator.loadViewController()
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentFavoriteGame(game: Game) {
            game.undoAll()
            var coordinator = GameCoordinator(for: game)
            let vc = coordinator.loadViewController()
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentPuzzle(puzzle: Puzzle) {
            print(#function)
        }

        vc.delegate = RootCollectionViewController.Delegate(
            didSelectUserGame: _presentUserGame,
            didSelectFavoriteGame: _presentFavoriteGame,
            didSelectPuzzle: _presentPuzzle
        )

    }

}

struct Puzzle {

}
