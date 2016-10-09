//
//  GameViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

public final class GameViewController: UIViewController, SegueHandlerType {

    var game: Game?
    var isEditable: Bool = false
    var save: (Game) -> () = { _ in }

    private var movementCoordinator: BoardMovementCoordinator?
    private var arrowsCoordinator: BoardArrowsCoordinator?
    private var coverageCoordinator: BoardCoverageCoordinator?
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
            let outcome = game.outcome.description
            vc.model = (game.whitePlayer.name, game.blackPlayer.name, outcome)

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
            guard let vc = segue.destination as? HistoryViewController else { fatalError() }
            vc.rows = {
                let moves = game.history.count + game.undoHistory.count
                let rows = 1 + moves + (moves % 2 == 0 ? moves/2 : (moves + 1)/2)
                return rows
            }

            vc.cellType = { index in
                return HistoryCellType(row: index, game: game)
            }

            vc.didSelect = didSelect

            updateHistory = {
                guard let collectionView = vc.collectionView else {
                    fatalError("Expected an unwrapped collection view")
                }
                collectionView.reloadData()
                let row = collectionView.numberOfItems(inSection: 0) - 1
                let indexPath = IndexPath(row: row, section: 0)
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .centeredHorizontally
                )
            }

            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.advanceMove(sender:)), direction: .left)
            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.reverseMove(sender:)), direction: .right)
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
