//
//  GameCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Endgame

public struct GameCoordinator {

    private let navigationController: UINavigationController
    private let game: Game
    private let scene: BoardScene
    private let isUserGame: Bool

    private let settingsViewCoordinator: SettingsViewCoordinator

    init(for game: Game, with navigationController: UINavigationController, isUserGame: Bool = false) {
        self.navigationController = navigationController
        self.game = game
        self.isUserGame = isUserGame
        self.scene = BoardScene()
        scene.scaleMode = .resizeFill
        self.settingsViewCoordinator = SettingsViewCoordinator(with: game)
    }

    func gameViewController() -> GameViewController {
        let vc = UIStoryboard.main.instantiate(GameViewController.self)
        vc.navigationItem.title = game.outcome.description
        return vc
    }

    func titleViewController(model: TitleViewDataSource) -> TitleViewController {
        let vc = UIStoryboard.main.instantiate(TitleViewController.self)
        vc.model = model
        return vc
    }

    func boardViewController(with delegate: BoardInteractionCoordinator) -> BoardViewController {
        let vc = UIStoryboard.main.instantiate(BoardViewController.self)
        vc.delegate = delegate
        return vc
    }

//    func historyViewController(model: HistoryViewDataSource, delegate: HistoryInteractionConfiguration) -> HistoryViewController {
//        let vc = UIStoryboard.main.instantiate(History.ViewController.self)
//        vc.model = model
//        vc.delegate = delegate
//        game.delegate = vc
//        return vc
//    }

    func captureViewController() -> CaptureViewController {
        let vc = UIStoryboard.main.instantiate(CaptureViewController.self)
        return vc
    }

    func start() {

        let vc = gameViewController()

        vc.captureViewController = captureViewController()

        let pieceModel = PieceNodeModel(
            scene: scene,
            captureViewDelegate: vc.captureViewController
        )
        let arrowModel = ArrowNodeModel(scene: self.scene)
        let squareModel = SquareNodeModel(scene: self.scene)

        let userActivityCoordinator = UserActivityCoordinator(
            game: game,
            pieceModel: pieceModel,
            arrowModel: arrowModel,
            squareModel: squareModel,
            presentingViewController: navigationController
        )

        let titleModel = TitleViewDataSource(for: game)
        vc.titleViewController = titleViewController(model: titleModel)

//        let historyModel = HistoryViewDataSource(for: game)
//        let historyDelegate = HistoryInteractionConfiguration(
//            pieceModel: pieceModel,
//            for: game,
//            with: userActivityCoordinator
//        )
//        vc.historyViewController = historyViewController(
//            model: historyModel,
//            delegate: historyDelegate
//        )
//        // Add left and right swipe gesture recognizers to the view, and target historyViewController
//        for direction in [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right] {
//            vc.view.addSwipeGestureRecognizer(
//                target: vc.historyViewController,
//                action: #selector(vc.historyViewController.handleSwipe),
//                direction: direction
//            )
//        }

        let boardInteractionCoordinator = BoardInteractionCoordinator(
            delegate: userActivityCoordinator,
            model: pieceModel
        )
        vc.boardViewController = boardViewController(with: boardInteractionCoordinator)

        // A block to present the scene in boardVC's view without boardVC knowing
        // about the scene. By this time, the board has it's size, so set the
        // scene's size to match as well and have place its nodes as well.
        func presentScene() {
            guard let skview = vc.boardViewController.view as? SKView else { fatalError() }
            self.scene.size = skview.bounds.size
            self.scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            squareModel.placeSquares()
            pieceModel.updatePieces(with: self.game.currentPosition.board)
            skview.presentScene(self.scene)

//            let currentIndexPath = vc.historyViewController.model.indexPath(for: game.currentIndex)
//            vc.historyViewController.collectionView?.selectItem(at: currentIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        vc.presentScene = presentScene

        func didFinishEditingSettings() {
            // Update board state based on changes in settings
        }
        let settingsViewDelegate = SettingsViewCoordinator.Delegate(
            settingsViewDidRotateBoard: vc.boardViewController.rotateView,
            settingsViewDidFinish: didFinishEditingSettings
        )
        vc.didTapSettingsButton = settingsViewCoordinator.start(
            with: settingsViewDelegate,
            navigationController: navigationController,
            orientation: { vc.boardViewController.currentOrientation }
        )

        vc.didTapBackButton = {
            self.save()
            self.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(vc, animated: true)

    }

    func save() {
        let pgn = game.pgn.exported()
        let cache = Cache(with: "game")
        cache.save(object: pgn as NSCoding)
    }

}

extension UIStoryboard {

    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    func instantiate<A: UIViewController>(_ type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }

}

extension UICollectionView {
    func dequeue<A: UICollectionViewCell>(_ cellType: A.Type, at indexPath: IndexPath) -> A {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: "\(cellType.self)", for: indexPath) as? A else { fatalError("Could not dequeue a cell of type: \(A.self)") }
        return cell
    }
}
