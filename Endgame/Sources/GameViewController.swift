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

    private var historyViewConfiguration: HistoryViewConfiguration?
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
            historyViewConfiguration = HistoryViewConfiguration(game: game, historyViewController: vc, moveSelectionHandler: didSelect)
            
            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.advanceMove(sender:)), direction: .left)
            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.reverseMove(sender:)), direction: .right)
        }

    }

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
            try game?.execute(move: move)
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

extension GameViewController: GameDelegate {

    public func game(_: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        
    }

    public func game(_: Game, didAdvance items: [HistoryItem]) {

    }

    public func game(_: Game, didReverse items: [HistoryItem]) {

    }
}
