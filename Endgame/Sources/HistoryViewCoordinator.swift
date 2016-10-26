//
//  HistoryViewCoordinator.swift
//  Endgame
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Engine

struct HistoryViewConfiguration: HistoryViewDataSource {

    private let game: Game

    init(for game: Game) {
        self.game = game
    }

    func cellCount() -> Int {
        let moves = game.count
        let cells = 1 + moves + (moves % 2 == 0 ? moves / 2 : (moves + 1) / 2) + 1
        return cells
    }

    func itemType(at indexPath: IndexPath) -> HistoryCellType {

        if isStart(for: indexPath) { return .start }
        if isOutcome(for: indexPath) { return .outcome(game.outcome) }
        if isNumberCell(for: indexPath) { return .number(fullmoveValue(for: indexPath)) }

        guard let itemIndex = itemIndex(for: indexPath) else { fatalError("Expected a move") }
        return .move(game[itemIndex].sanMove)

    }

    func itemIndex(for indexPath: IndexPath) -> Int? {
        let row = indexPath.row
        guard row != 0 else { return nil }
        return 2 * row / 3 - 1
    }

}
