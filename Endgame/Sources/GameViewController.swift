//
//  GameViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

struct GameViewCoordinator {

    var game: Game

    init(game: Game) {
        self.game = game
    }

}

public final class GameViewController: UIViewController, SegueHandlerType {

    var game: Game?
    var historyViewConfiguration: HistoryViewConfiguration?
    var boardMovementCoordinator: BoardMovementCoordinator?


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
            boardMovementCoordinator = BoardMovementCoordinator(
                pieceNode: vc.pieceNode,
                newPieceNode: vc.newPieceNode,
                perform: vc.perform
            )
            

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
        boardMovementCoordinator?.arrange(items: items, direction: direction)
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
