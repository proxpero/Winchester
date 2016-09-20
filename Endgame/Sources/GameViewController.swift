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

    var game = Game()
    var update: ([Move]) -> () = { _ in }

    enum SegueIdentifier: String {
        case title = "TitleViewControllerSegueIdentifier"
        case board = "BoardViewControllerSegueIdentifier"
        case history = "HistoryViewControllerSegueIdentifier"
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segueIdentifierForSegue(segue) {

        case .title:
            guard let vc = segue.destination as? TitleViewContoller else { fatalError() }
            let outcome = game.outcome?.description ?? "vs"
            vc.model = (game.whitePlayer.name, game.blackPlayer.name, outcome)

        case .board:
            guard let vc = segue.destination as? BoardViewController else { fatalError() }
            vc.availableMoves = availableMoves
            vc.execute = execute
            update = vc.update

        case .history:
            guard let vc = segue.destination as? HistoryViewController else { fatalError() }
            vc.game = game
            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.advanceMove(sender:)), direction: .left)
            view.addSwipeGestureRecognizer(target: vc, action: #selector(vc.reverseMove(sender:)), direction: .right)
            vc.moveSelectionHandler = selectMove
        }

    }

    func availableMoves(from origin: Square) -> Bitboard {
        return game.moves(from: origin)
    }

    func execute(move: Move) -> Bool {
        do {
            try game.execute(move: move)
            return true
        } catch {
            print("Could not perform move: \(move.description)")
            return false
        }
    }

    func selectMove(at index: Int) {
        print(game.moveHistory[index])
        let moves: [Move] = []
        // Get the diff between current board and new board
        update(moves)
    }

    var didSelect: (Game) -> () = { _ in }
    var didTapConfigure: () -> () = { }

}
