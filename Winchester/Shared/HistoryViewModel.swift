//
//  HistoryViewModel.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation

protocol HistoryViewModel {

    /// The number of cells in the History View Control.
    func cellCount() -> Int

    /// Provides a `HistoryCellType` suitable for the cell at `indexPath
    func itemType(at indexPath: IndexPath) -> HistoryCellType

    /// Returns the index for the `HistoryItem` in the game, or `nil` if
    /// at the starting position.
    func itemIndex(for indexPath: IndexPath) -> Int?

}

extension HistoryViewModel {

    // MARK: Internal Computed Properties and Functions

    func lastMove() -> IndexPath {
        return IndexPath(row: cellCount() - 2, section: 0)
    }

    func nextMoveCell(after indexPath: IndexPath) -> IndexPath {
        let next = indexPath.row + 1
        let candidate = IndexPath(row: next, section: 0)
        if isNumberCell(for: candidate) {
            return IndexPath(row: next+1, section: 0)
        } else {
            return candidate
        }
    }

    func previousMoveCell(before indexPath: IndexPath) -> IndexPath {
        let prev = indexPath.row - 1
        let candidate = IndexPath(row: prev, section: 0)
        if isNumberCell(for: candidate) {
            return IndexPath(row: prev-1, section: 0)
        } else {
            return candidate
        }
    }

    func isValidSelection(for indexPath: IndexPath) -> Bool {
        return (0 ..< cellCount()-1).contains(indexPath.row)
    }

    func isStart(for indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    func isOutcome(for indexPath: IndexPath) -> Bool {
        return indexPath.row == cellCount() - 1
    }

    func isNumberCell(for indexPath: IndexPath) -> Bool {
        return (indexPath.row-1) % 3 == 0
    }

    func indexPath(for itemIndex: Int?) -> IndexPath {
        guard let itemIndex = itemIndex else { return IndexPath(row: 0, section: 0) }
        let row = ((itemIndex % 2 == 0 ? 2 : 0) + (6 * (itemIndex + 1))) / 4
        return IndexPath(row: row, section: 0)
    }

    func fullmoveValue(for indexPath: IndexPath) -> Int {
        return (indexPath.row - 1) / 3 + 1
    }
    
}
