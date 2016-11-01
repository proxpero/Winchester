//
//  AppCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

struct ApplicationCoordinator {

    struct Model {
        let updateUserGames: () -> [Game]
        let updateClassicGames: () -> [Game]
    }

    // MARK: - Private Stored Properties

    private let _navigationController: UINavigationController
    private let _model: Model

    // MARK: - Initializers

    init(
        window: UIWindow,
        model: Model)
    {
        self._navigationController = window.rootViewController as! UINavigationController
        self._model = model
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
            userGames: _model.updateUserGames(),
            classicGames: _model.updateClassicGames()
        )

        // MARK: Delegate

        func _presentUserGame(game: Game) {
            let coordinator = GameCoordinator(for: game, with: _navigationController)
            coordinator.start()
        }

        func _presentFavoriteGame(game: Game) {
            let coordinator = GameCoordinator(for: game, with: _navigationController)
            coordinator.start()
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
