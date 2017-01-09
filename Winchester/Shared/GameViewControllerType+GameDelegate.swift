//
//  GameViewControllerType+GameDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

extension GameViewControllerType {

    public func game(_ game: Game, didAppend item: HistoryItem, at index: Int?) {
        historyViewController?.updateCell(at: index)
    }

    public func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction) {
        guard let boardView = boardViewController?.view as? BoardView else { fatalError("Programmer Error: Expected a boardView") }
        boardView.traverse(items, in: direction)
        boardViewDidNormalizeActivity(boardView)
    }

    public func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        normalize()
    }

    public func game(_ game: Game, didEndWith outcome: Outcome) {}

    public func normalize() {
        guard let boardView = boardViewController?.view as? BoardView else { fatalError("Programmer Error: Expected a boardView") }
        let delay = DispatchTime.now() + .milliseconds(30)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.boardViewDidNormalizeActivity(boardView)
        }
    }
}
