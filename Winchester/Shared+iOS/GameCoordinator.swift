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

        let storyboard = UIStoryboard.game

        let gameViewController = storyboard.instantiate(GameViewController.self)
        gameViewController.game = game
        game.delegate = gameViewController

        // MARK: BoardViewController

        let boardViewController = storyboard.instantiate(BoardViewController.self)
        boardViewController.boardView.updatePieces(with: game.currentPosition.board)
        boardViewController.delegate = gameViewController
        gameViewController.boardViewController = boardViewController

        // MARK: HistoryViewController

        let historyViewController = storyboard.instantiate(HistoryViewController.self)
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

        gameViewController.capturedPiecesViewController = storyboard.instantiate(CapturedPiecesViewController.self)
        if let capturedView = gameViewController.capturedPiecesViewController?.view as? CapturedPiecesView {
            gameViewController.boardViewController?.boardView.pieceCapturingViewDelegate = capturedView
        }

        boardViewController.boardView.updatePieces(with: game.currentPosition.board)
        return gameViewController
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

