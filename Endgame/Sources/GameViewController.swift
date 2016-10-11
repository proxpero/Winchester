//
//  GameViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

enum ActivityState {
    case initiation(Square)
    case normal
    case end(Move)
}

public final class GameViewController: UIViewController, SegueHandlerType {

    var game: Game?
    var isEditable: Bool = false
    var save: (Game) -> () = { _ in }

    private var historyCoordinator: HistoryCoordinator?
    private var movementCoordinator: BoardMovementCoordinator?
    private var arrowsCoordinator: BoardArrowsCoordinator?
    private var interactionCoordinator: BoardInteractionCoordinator?

    enum SegueIdentifier: String {
        case title = "TitleViewControllerSegueIdentifier"
        case board = "BoardViewControllerSegueIdentifier"
        case history = "HistoryViewControllerSegueIdentifier"
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let game = game else { fatalError() }
        switch segueIdentifierForSegue(segue) {

        case .title:
            guard let vc = segue.destination as? TitleViewContoller else { fatalError() }
            vc.model = (game.whitePlayer, game.blackPlayer, game.outcome)

        case .board:
            guard let vc = segue.destination as? BoardViewController else { fatalError() }
            
            movementCoordinator = BoardMovementCoordinator(
                pieceNode: vc.pieceNode,
                newPieceNode: vc.newPieceNode,
                perform: vc.perform
            )
            arrowsCoordinator = BoardArrowsCoordinator(
                showLastMove: vc.showLastMove,
                addArrow: vc.addArrow
            )
            interactionCoordinator = BoardInteractionCoordinator(
                userDidExecute: userDidExecute,
                pieceNode: vc.pieceNode,
                position: vc.position,
                availableTargets: game.availableTargets,
                highlightAvailableTargets: vc.highlightAvailableTargets,
                execute: vc.execute,
                removeHighlights: vc.removeHighlights
            )
            vc.userDidSelect = interactionCoordinator!.userDidSelect

        case .history:
            guard
            let vc = segue.destination as? HistoryViewController,
            let collectionView = vc.collectionView
            else { fatalError() }

            historyCoordinator = HistoryCoordinator()

            vc.cellType = historyCoordinator!.cellType(game)
            vc.rows = historyCoordinator!.rows(game)
            updateHistory = historyCoordinator!.update(collectionView)
            vc.didSelect = didSelect

            view.addSwipeGestureRecognizer(
                target: vc,
                action: #selector(vc.advanceMove(sender:)),
                direction: .left
            )

            view.addSwipeGestureRecognizer(
                target: vc,
                action: #selector(vc.handleSwipe(recognizer:)),
                direction: .right
            )
        }

    }

    var updateHistory: () -> Void = { }

    func didSelect(rowAt index: Int) {
        guard let game = game else {
            fatalError()
        }
        let (direction, items) = game.move(to: index)
        movementCoordinator?.arrange(items: items, direction: direction)
        arrowsCoordinator?.showLastMove(game.lastMove)
    }

    func userDidExecute(move: Move) {
        do {
            guard let game = game else { fatalError("A game was expected.") }
            if game.isPromotion(for: move) {
                
            }
            try game.execute(move: move)
            updateHistory()
            save(game)
        } catch {
            print("ERROR: Could not execute move: \(move)")
        }
    }

    func availableSquares(for origin: Square) -> [Square] {
        guard let game = game else {
            fatalError()
        }
        return game.availableTargets(forPieceAt: origin)
    }
}
