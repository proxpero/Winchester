//
//  History.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

enum History { }

protocol HistoryViewControllerType: class {

    var delegate: History.Delegate! { get set }
    var dataSource: History.DataSource! { get set }

}

protocol HistoryViewDelegate {
    /// Called when the user selects a cell in the HistoryView.
    ///
    /// - Parameter itemIndex: The index of the history item in the game.
    func userDidSelectHistoryItem(at itemIndex: Int?)
}

protocol HistoryViewDataSource {

    /// The number of cells in the History View Control.
    func cellCount() -> Int

    /// Provides a `HistoryCellType` suitable for the cell at `indexPath
    func itemType(at indexPath: IndexPath) -> History.CellType

    /// Returns the index for the `HistoryItem` in the game, or `nil` if
    /// at the starting position.
    func itemIndex(for indexPath: IndexPath) -> Int?

}

extension HistoryViewDataSource {

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

extension History {

    struct Coordinator {

        private let pieceNodeModel: PieceNodeModel
        private let game: Game
        private let userActivityDelegate: UserActivityDelegate

        init(game: Game, pieceNodeModel: PieceNodeModel, userActivityDelegate: UserActivityDelegate) {
            self.pieceNodeModel = pieceNodeModel
            self.game = game
            self.userActivityDelegate = userActivityDelegate
        }

        func configure(_ viewController: HistoryViewControllerType) {
            let delegate = Delegate(pieceModel: pieceNodeModel, for: game, with: userActivityDelegate)
            let dataSource = DataSource(for: game)
            viewController.delegate = delegate
            viewController.dataSource = dataSource
        }

    }

}

extension History {
    
    struct Delegate: HistoryViewDelegate {

        private let pieceModel: PieceNodeModel
        private let game: Game
        private let userActivityDelegate: UserActivityDelegate?

        init(pieceModel: PieceNodeModel, for game: Game, with userActivityDelegate: UserActivityDelegate?) {
            self.pieceModel = pieceModel
            self.game = game
            self.userActivityDelegate = userActivityDelegate
        }

        func userDidSelectHistoryItem(at itemIndex: Int?) {
            guard let (direction, items) = game.settingIndex(to: itemIndex) else { return }
            mobilize(items, toward: direction)
            userActivityDelegate?.userDidNormalizeActivity()
        }

        // Move the pieces from where they are to where they need to be.
        private func mobilize(_ items: [HistoryItem], toward direction: Direction) {

            typealias TransactionTable = Dictionary<PieceNode, Transaction>

            // An object to encapsulate what needs to happen to each piece.
            struct Transaction {
                enum Status {
                    case added
                    case removed
                    case normal
                    case captured
                    case resurrected

                    func isRemoved() -> Bool {
                        return self == .removed || self == .captured
                    }

                    func isAdded() -> Bool {
                        return self == .added || self == .resurrected
                    }

                    func isNormal() -> Bool {
                        return self == .normal
                    }

                }
                var origin: Square
                var target: Square
                var status: Status
            }

            // Create a table of the pieceNodes that are affected by the change and their origins and final resting places.
            func consolidate(items: [HistoryItem], direction: Direction) -> TransactionTable {
                var result: TransactionTable = [:]

                func findNode(for square: Square) -> PieceNode {
                    // If the pieceNode has been moved already
                    func node(at square: Square) -> PieceNode? {
                        let nodes = result
                            .filter { $0.value.target == square && !$0.value.status.isRemoved() }
                            .map { $0.key }
                        guard nodes.count == 1 else { return nil }
                        return nodes[0]
                    }
                    if let candidate = node(at: square) {
                        return candidate
                    }
                    if let candidate = pieceModel.pieceNode(for: square) {
                        //                if let candidate = delegate.pieceNode(at: square) {
                        return candidate
                    }
                    fatalError("Unable to find a pieceNode at \(square.description)")
                }

                // Determine how `item` fits in with the transactions already considered.
                func apprehend(item: HistoryItem) {

                    let node = findNode(for: direction.isRedo ? item.move.origin : item.move.target)

                    var transaction: Transaction = {

                        let move = direction.isUndo ? item.move.reversed() : item.move

                        if var candidate = result[node] {
                            candidate.target = move.target
                            return candidate
                        }

                        return Transaction(
                            origin: move.origin,
                            target: move.target,
                            status: .normal)
                    }()

                    if let capture = item.capture {
                        switch direction {
                        case .redo:
                            let capturedNode = findNode(for: capture.square)
                            // If `result` has registered the captured piece already, modify that transaction...
                            if var captureTransaction = result[capturedNode] {
                                captureTransaction.status = .captured
                                captureTransaction.target = capture.square
                                result.updateValue(captureTransaction, forKey: capturedNode)
                            } else { // ... otherwise create a new transaction.
                                result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .captured)
                            }
                            result.updateValue(transaction, forKey: node)
                        case .undo:
                            let capturedNode = pieceModel.pieceNode(for: capture.piece)
                            result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .resurrected)
                        }
                    }

                    if let promotion = item.promotion {
                        // In either direction, the pieceNode is removed and a new piece is added, either a pawn or the chosen promotion.
                        transaction.status = .removed
                        let piece = direction.isRedo ? promotion : Piece(pawn: promotion.color)
                        let move = direction.isRedo ? item.move : item.move.reversed()
                        result[pieceModel.pieceNode(for: piece)] = Transaction(origin: move.origin, target: move.target, status: .added)
                    }

                    // If a castle is involved then the rook need to be moved and added to the table.
                    if item.move.isCastle() {
                        let (old, new) = item.move.castleSquares()
                        let rookNode = findNode(for: direction.isRedo ? old : new)

                        switch direction {
                        case .redo:
                            result[rookNode] = Transaction(origin: old, target: new, status: .normal)
                        case .undo:
                            var rookTransaction = result[rookNode] ?? Transaction(origin: old, target: new, status: .normal)
                            rookTransaction.target = old
                            result[rookNode] = rookTransaction
                        }
                    }
                    result[node] = transaction
                }

                let elements = direction.isRedo ? items : items.reversed()
                elements.forEach(apprehend)
                return result
            }

            func perform(_ transaction: Transaction, on pieceNode: PieceNode) {
                if transaction.status == .removed {
                    pieceModel.remove(pieceNode)
                } else if transaction.status == .captured {
                    pieceModel.capture(pieceNode)
                } else {
                    if transaction.status == .added {
                        pieceModel.add(pieceNode, at: transaction.origin)
                    } else if transaction.status == .resurrected {
                        pieceModel.resurrect(pieceNode, at: transaction.origin)
                    }
                    pieceModel.move(pieceNode, to: transaction.target)
                }
            }
            
            // Move each piece in the transaction table to its right place.
            for (pieceNode, transaction) in consolidate(items: items, direction: direction) {
                // Add, remove, or move the piece based on its transaction.
                perform(transaction, on: pieceNode)
            }
        }

    }
}

extension History {

    struct DataSource: HistoryViewDataSource {

        private let game: Game

        init(for game: Game) {
            self.game = game
        }

        func cellCount() -> Int {
            let moves = game.count
            let startCells = 1
            let moveCells = moves
            let numberCells = moves % 2 == 0 ? moves / 2 : (moves + 1) / 2
            let outcomeCells = 1
            return startCells + moveCells + numberCells + outcomeCells
        }

        func itemType(at indexPath: IndexPath) -> History.CellType {

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

}

import SpriteKit

extension History {
    
    enum CellType {

        case start
        case number(Int)
        case move(String)
        case outcome(Outcome)

        // MARK: - Internal Functions

        func configureCell(cell: HistoryCell) {
            cell.label.text = self.text
            cell.isBordered = self.isBordered
            cell.label.textAlignment = self.textAlignment
        }

        var shouldBeSelected: Bool {
            switch self {
            case .start: return true
            case .number: return false
            case .move: return true
            case .outcome: return false
            }
        }

        var width: CGFloat {
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


        static func == (lhs: History.CellType, rhs: History.CellType) -> Bool {
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

