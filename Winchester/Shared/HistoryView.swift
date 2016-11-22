//
//  HistoryView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

public protocol HistoryViewControllerType: class, ViewControllerType {

    weak var delegate: HistoryViewDelegate? { get set }
    weak var dataSource: HistoryViewDataSource? { get set }
    func updateCell(at itemIndex: Int?)
}

extension HistoryViewControllerType where Self: CollectionViewController {
    public func updateCell(at itemIndex: Int?) {
        guard let indexPath = dataSource?.indexPath(for: itemIndex) else { return }
        collectionView?.reloadData()
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

public protocol HistoryViewDelegate: class {
    /// Called when the user selects a cell in the HistoryView.
    ///
    /// - Parameter itemIndex: The index of the history item in the game.
    func userDidSelectHistoryItem(at itemIndex: Int?)
}

public protocol HistoryViewDataSource: class {

    /// This `game` instance should be private to this protocol and should not be modified. It is read-only.
    weak var game: Game? { get }

    /// The number of cells in the History View Control.
    func cellCount() -> Int

    /// Provides a `HistoryCellType` suitable for the cell at `indexPath
    func itemType(at indexPath: IndexPath) -> HistoryView.CellType

    /// Returns the index for the `HistoryItem` in the game, or `nil` if
    /// at the starting position.
    func itemIndex(for indexPath: IndexPath) -> Int?

}

extension HistoryViewDataSource {

    // MARK: - Default implementation of protocol.

    public func cellCount() -> Int {
        guard let game = game else { fatalError("Expected a game") }

        let moves = game.count
        let startCells = 1
        let moveCells = moves
        let numberCells = moves % 2 == 0 ? moves / 2 : (moves + 1) / 2
        let outcomeCells = 1
        return startCells + moveCells + numberCells + outcomeCells
    }

    public func itemType(at indexPath: IndexPath) -> HistoryView.CellType {
        guard let game = game else { fatalError("Expected a game") }

        if isStart(for: indexPath) { return .start }
        if isOutcome(for: indexPath) { return .outcome(game.outcome) }
        if isNumberCell(for: indexPath) { return .number(fullmoveValue(for: indexPath)) }

        guard let itemIndex = itemIndex(for: indexPath) else { fatalError("Expected a move") }
        return .move(game[itemIndex].sanMove)

    }

    public func itemIndex(for indexPath: IndexPath) -> Int? {
        let row = indexPath.row
        guard row != 0 else { return nil }
        return 2 * row / 3 - 1
    }

    public func nextMoveCell(after indexPath: IndexPath) -> IndexPath {
        let next = indexPath.row + 1
        let candidate = IndexPath(row: next, section: 0)
        if isNumberCell(for: candidate) {
            return IndexPath(row: next+1, section: 0)
        } else {
            return candidate
        }
    }

    public func previousMoveCell(before indexPath: IndexPath) -> IndexPath {
        let prev = indexPath.row - 1
        let candidate = IndexPath(row: prev, section: 0)
        if isNumberCell(for: candidate) {
            return IndexPath(row: prev-1, section: 0)
        } else {
            return candidate
        }
    }

    public func lastMove() -> IndexPath {
        return IndexPath(row: cellCount() - 2, section: 0)
    }

    public func isValidSelection(for indexPath: IndexPath) -> Bool {
        return (0 ..< cellCount()-1).contains(indexPath.row)
    }

    public func isStart(for indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    public func isOutcome(for indexPath: IndexPath) -> Bool {
        return indexPath.row == cellCount() - 1
    }

    public func isNumberCell(for indexPath: IndexPath) -> Bool {
        return (indexPath.row-1) % 3 == 0
    }

    public func indexPath(for itemIndex: Int?) -> IndexPath {
        guard let itemIndex = itemIndex else { return IndexPath(row: 0, section: 0) }
        let row = ((itemIndex % 2 == 0 ? 2 : 0) + (6 * (itemIndex + 1))) / 4
        return IndexPath(row: row, section: 0)
    }

    public func fullmoveValue(for indexPath: IndexPath) -> Int {
        return (indexPath.row - 1) / 3 + 1
    }
    
}

public enum HistoryView { }

public protocol HistoryCellType: class {

    func setText(text: String)
    func setIsBordered(isBordered: Bool)
    func setTextAlignment(textAlignment: NSTextAlignment)

}

extension HistoryView {

    public enum CellType: Equatable {

        case start
        case number(Int)
        case move(String)
        case outcome(Outcome)

        public func configureCell(cell: HistoryCellType) {
            cell.setText(text: self.text)
            cell.setIsBordered(isBordered: self.isBordered)
            cell.setTextAlignment(textAlignment: self.textAlignment)
        }

        public var shouldBeSelected: Bool {
            switch self {
            case .start: return true
            case .number: return false
            case .move: return true
            case .outcome: return false
            }
        }

        public var width: CGFloat {
            switch self {
            case .start: return 80.0
            case .number: return 45.0
            case .move: return 70.0
            case .outcome: return 80.0
            }
        }

        // MARK: - Private Computed Properties and Functions

        private var text: String {
            switch self {
            case .start: return "Start"
            case .number(let n): return "\(n)."
            case .move(let m): return m.replacingOccurrences(of: "x", with: "×")
            case .outcome(let outcome): return outcome.userDescription
            }
        }

        private var textAlignment: NSTextAlignment {
            switch self {
            case .start: return .center
            case .number: return .right
            case .move: return .center
            case .outcome: return .center
            }
        }

        private var isBordered: Bool {
            switch self {
            case .number: return false
            case .outcome: return false
            default: return true
            }
        }

        public static func == (lhs: HistoryView.CellType, rhs: HistoryView.CellType) -> Bool {
            switch (lhs, rhs) {
            case (.start, .start): return true
            case (.number(let a), .number(let b)): return a == b
            case (.move(let a), .move(let b)): return a == b
            case (.outcome(let a), .outcome(let b)): return a == b
            default:
                return false
            }
        }

    }
}

