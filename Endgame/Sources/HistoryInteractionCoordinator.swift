//
//  HistoryInteractionCoordinator.swift
//  Endgame
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine

struct HistoryInteractionConfiguration: HistoryViewDelegate {

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

    private func mobilize(_ items: [HistoryItem], toward direction: Direction) {

        typealias TransactionTable = Dictionary<PieceNode, Transaction>

        struct Transaction {
            enum Status {
                case added
                case removed
                case normal
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
                        .filter { $0.value.target == square && $0.value.status != .removed }
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
                            captureTransaction.status = .removed
                            captureTransaction.target = capture.square
                            result.updateValue(captureTransaction, forKey: capturedNode)
                        } else { // ... otherwise create a new transaction.
                            result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .removed)
                        }
                        result.updateValue(transaction, forKey: node)
                    case .undo:
                        let capturedNode = pieceModel.pieceNode(for: capture.piece)
                        //                        let captureNode = delegate.newPiceNode(for: capture.piece)
                        result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .added)
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
            } else {
                if transaction.status == .added {
                    pieceModel.add(pieceNode, at: transaction.origin)
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


