//
//  GameDelegate.swift
//  Endgame
//
//  Created by Todd Olsen on 11/11/16.
//
//

import Foundation

public protocol GameDelegate: class {

    ///
    func game(_ game: Game, moveIndexDidChange oldIndex: Int, to newIndex: Int)

    ///
    func game(_ game: Game, didAppend event: Event, at index: Int?)

    ///
    func game(_ game: Game, didTraverse events: ArraySlice<Game.Event>, in direction: Game.Event.Direction, with transactions: Set<Transaction>)

    ///
    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?)

    ///
    func game(_ game: Game, didEndWith outcome: Outcome)

    ///
    func game(_ game: Game, didRecalculateECO eco: ECO)

}

extension GameDelegate {

    func game(_ game: Game, moveIndexDidChange oldIndex: Int, to newIndex: Int) {}

    ///
    func game(_ game: Game, didAppend event: Event, at index: Int?) {}

    ///
    func game(_ game: Game, didTraverse events: ArraySlice<Game.Event>, in direction: Game.Event.Direction, with transactions: Set<Transaction>) {}

    ///
    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {}

    ///
    func game(_ game: Game, didEndWith outcome: Outcome) {}

    ///
    func game(_ game: Game, didRecalculateECO eco: ECO) {}

}
