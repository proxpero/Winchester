//
//  GameDelegate.swift
//  Endgame
//
//  Created by Todd Olsen on 11/11/16.
//
//

import Foundation

public protocol GameDelegate: class {
    func game(_ game: Game, didAppend item: HistoryItem, at index: Int?)
    func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction)
    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?)
    func game(_ game: Game, didEndWith outcome: Outcome)
}
