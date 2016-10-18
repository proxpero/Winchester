//
//  GameViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

typealias PromotionHandler = (Piece?) -> ()

enum ActivityState {
    case initiation(Square)
    case normal
    case end(Move)
}

public final class GameViewController: UIViewController, SegueHandlerType {

    var game: Game?
    var isEditable: Bool = false
    var save: (Game) -> () = { _ in }
    var updateHistory: () -> Void = { }

    fileprivate var movementCoordinator: BoardMovementCoordinator?
    fileprivate var arrowsCoordinator: BoardArrowsCoordinator?
    fileprivate var interactionCoordinator: BoardInteractionCoordinator?
}

extension GameViewController {

    struct Delegate {
        let userDidExecute: (Move, Piece?) -> ()
        let updateHistory: () -> ()
        let save: (Game) -> ()
        let isEditable: Bool
    }
}

extension GameViewController {

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
            vc.model = TitleViewContoller.Model(
                white: game.whitePlayer,
                black: game.blackPlayer,
                outcome: game.outcome
            )

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
                availableCaptures: game.availableCaptures,
                highlightAvailableTargets: vc.highlightAvailableTargets,
                highlightAvailableCaptures: vc.highlightAvailableCaptures,
//                animateNode: { _ in },
//                animateNode: vc.animateNode,
                removeHighlights: vc.removeHighlights
            )
            vc.userDidSelect = interactionCoordinator!.userDidSelect

        case .history:
            guard let vc = segue.destination as? HistoryViewController else { fatalError() }
            vc.delegate = HistoryViewController.Delegate(didSelectItem: self.didSelect)
            vc.model = HistoryViewController.Model(for: game)

            self.updateHistory = vc.update
            
            [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right]
                .forEach { direction in
                    view.addSwipeGestureRecognizer(
                        target: vc,
                        action: #selector(vc.handleSwipe(recognizer:)),
                        direction: direction
                    )
            }
        }
    }


    func didSelect(rowAt index: Int?) {

        guard let game = game else { fatalError() }
        guard let result = game.settingIndex(to: index) else {
            return
        }

        movementCoordinator?.arrange(items: result.items, direction: result.direction)
        arrowsCoordinator?.showLastMove(game.latestMove)

    }

    func userDidExecute(move: Move, promotion: Piece?) {
        do {
            guard let game = game else { fatalError("A game was expected.") }

            if game.isPromotion(for: move) {

            } else {
                try game.execute(move: move)
                updateHistory()
                save(game)
            }
        } catch {
            print("ERROR: Could not execute move: \(move)")
        }
    }

}
