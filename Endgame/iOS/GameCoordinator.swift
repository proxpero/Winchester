//
//  GameCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Engine

public struct GameCoordinator {

    private let navigationController: UINavigationController
    private let game: Game
    private let scene: BoardScene

    init(for game: Game, with navigationController: UINavigationController) {

        game.undoAll()

        self.navigationController = navigationController
        self.game = game
        self.scene = BoardScene()
        scene.scaleMode = .resizeFill
        
    }

    func start() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let pieceModel = PieceNodeModel(scene: self.scene)
        let arrowModel = ArrowNodeModel(scene: self.scene)
        let squareModel = SquareNodeModel(scene: self.scene)

        let userActivityCoordinator = UserActivityCoordinator(
            game: game,
            pieceModel: pieceModel,
            arrowModel: arrowModel,
            squareModel: squareModel
        )

        guard let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { fatalError() }
        gameVC.boardInteractionCoordinator = BoardInteractionCoordinator(delegate: userActivityCoordinator, model: pieceModel)
        gameVC.userActivityCoordinator = userActivityCoordinator

        guard let titleVC = storyboard.instantiateViewController(withIdentifier: "TitleViewController") as? TitleViewContoller else { fatalError("Couldn't create TitleViewController") }
        
        titleVC.dataSource = TitleViewConfiguration(for: game)

        gameVC.titleViewController = titleVC

        guard let boardViewController = storyboard.instantiateViewController(withIdentifier: "BoardViewController") as? BoardViewController else { fatalError() }
        
        gameVC.boardViewController = boardViewController

        guard let historyViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController else { fatalError() }
        historyViewController.model = HistoryViewConfiguration(for: game)
        historyViewController.delegate = HistoryInteractionConfiguration(
            pieceModel: pieceModel,
            for: game,
            with: userActivityCoordinator
        )

        // Add left and right swipe gesture recognizers to the view.
        for direction in [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right] {
            gameVC.view.addSwipeGestureRecognizer(
                target: historyViewController,
                action: #selector(historyViewController.handleSwipe(recognizer:)),
                direction: direction
            )
        }

        gameVC.historyViewController = historyViewController

        func presentScene() {
            guard let boardVC = gameVC.boardViewController, let skview = boardVC.view as? SKView else { fatalError() }
            self.scene.size = boardVC.view.bounds.size
            squareModel.placeSquares()
            pieceModel.updatePieces(with: self.game.currentPosition.board)
            skview.presentScene(self.scene)
            historyViewController.collectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }

        gameVC.presentScene = presentScene

        navigationController.pushViewController(gameVC, animated: true)
    }
}

//extension GameCoordinator: User

typealias BoardResizingEventHandler = () -> (BoardScene)
