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
import Shared

public struct GameCoordinator {

    private let game: Game
    private let isUserGame: Bool

    public init(for game: Game, isUserGame: Bool = false) {
        self.game = game
        self.isUserGame = isUserGame
    }

    @discardableResult
    public mutating func loadViewController() -> GameViewController {

        let gameViewController = UIStoryboard.game.instantiate(GameViewController.self)
        gameViewController.game = game
        game.delegate = gameViewController

        // MARK: BoardViewController

        let boardViewController = UIStoryboard.game.instantiate(BoardViewController.self)
        boardViewController.boardView.updatePieces(with: game.currentPosition.board)
        boardViewController.delegate = gameViewController
        gameViewController.boardViewController = boardViewController

        // MARK: HistoryViewController

        let historyViewController = UIStoryboard.game.instantiate(HistoryViewController.self)
        historyViewController.delegate = gameViewController
        historyViewController.dataSource = gameViewController
        let currentIndexPath = gameViewController.indexPath(for: game.currentIndex)
        historyViewController.collectionView?.selectItem(at: currentIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        gameViewController.historyViewController = historyViewController

        for direction in [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right] {
            gameViewController.view.addSwipeGestureRecognizer(
                target: historyViewController,
                action: .handleSwipe,
                direction: direction
            )
        }

        gameViewController.capturedPiecesViewController = UIStoryboard.game.instantiate(CapturedPiecesViewController.self)
        if let capturedView = gameViewController.capturedPiecesViewController?.view as? CapturedPiecesView {
            gameViewController.boardViewController?.boardView.pieceCapturingViewDelegate = capturedView
        }

//        gameViewController.navigationItem.title = game.outcome.description

//        let settingsViewDelegate = SettingsViewCoordinator.Delegate(
//            game: game,
//            settingsViewDidRotateBoard: vc.boardViewController!.boardView.rotateView
//        )
//        vc.didTapSettingsButton = settingsViewCoordinator.start(
//            with: settingsViewDelegate,
//            navigationController: navigationController,
//            orientation: { vc.boardViewController!.boardView.currentOrientation }
//        )

        gameViewController.didTapBackButton = backButtonHandler
//        navigationController.pushViewController(gameViewController, animated: true)

        return gameViewController
    }

    func backButtonHandler() {
        save()
//        guard let gameViewController = navigationController.popViewController(animated: true) as? GameViewController else { return }
//        gameViewController.boardViewController = nil
        if isUserGame {
            save()
        }
        
    }

    func save() {
        let pgn = game.pgn.exported()
        var pgns = UserDefaults.standard.array(forKey: "user-games") as? [String] ?? [String]()
        pgns.append(pgn)
        UserDefaults.standard.set(pgns, forKey: "user-games")
    }

}

fileprivate extension Selector {
    static let handleSwipe = #selector(HistoryViewController.handleSwipe(_:))
}

extension UIStoryboard {

    static var game: UIStoryboard {
        let bundle = Bundle(for: GameViewController.self)
        return UIStoryboard(name: "Game", bundle: bundle)
    }

    func instantiate<A: UIViewController>(_ type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }

}


