//
//  AppCoordinator.swift
//  Endgame
//
//  Created by Todd Olsen on 10/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import UIKit

struct ApplicationCoordinator {

    struct Model {
        let updateUserGames: () -> [Game]
        let updateFavoriteGames: () -> [Game]
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
            favoriteGames: _model.updateFavoriteGames()
        )

        // MARK: Delegate

        func _gameViewController() -> GameViewController {
            guard let vc = UIStoryboard(name: "Game", bundle: Bundle(for: GameViewController.self)).instantiateInitialViewController() as? GameViewController else { fatalError("Could not create Game View Controller") }
            return vc
        }

        func _presentGame(_ game: Game) {
            let vc = _gameViewController()
            game.undoAll()
            vc.game = game        
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentNewGame() {
            let vc = _gameViewController()
            vc.game = Game()
            vc.isEditable = true
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentUserGame(game: Game) {
            let vc = _gameViewController()
            vc.game = game
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentAllUserGames() {
            print(#function)
        }

        func _presentFavoriteGame(game: Game) {
            let vc = _gameViewController()
            vc.game = game
            vc.isEditable = false
            _navigationController.pushViewController(vc, animated: true)
        }

        func _presentAllFavoriteGames() {
            print(#function)
        }

        func _presentPuzzle(puzzle: Puzzle) {
            print(#function)
        }

        func _presentAllPuzzles() {
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
