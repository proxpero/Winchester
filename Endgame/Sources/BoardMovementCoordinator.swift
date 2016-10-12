//
//  BoardMovementCoordinator.swift
//  GameViewDemo
//
//  Created by Todd Olsen on 10/6/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import Engine
import SpriteKit

typealias MoveTable = Dictionary<PieceNode, Transaction>

protocol TransactionType {
    var origin: Square { get set }
    var target: Square { get set }
    var status: Transaction.Status { get set }
}

struct Transaction: TransactionType {
    enum Status {
        case added
        case removed
        case normal
    }
    var origin: Square
    var target: Square
    var status: Status
}

final class BoardMovementCoordinator {

    // MARK: - Stored Properties

    private let getPieceNode: (Square) -> PieceNode?
    private let newPieceNode: (Piece) -> PieceNode
    private let perform: (Transaction, PieceNode) -> ()

    // MARK: - Initializers

    init(
        pieceNode: @escaping (Square) -> PieceNode?,
        newPieceNode: @escaping (Piece) -> PieceNode,
        perform: @escaping (Transaction, PieceNode) -> ()
        ) {
        self.getPieceNode = pieceNode
        self.newPieceNode = newPieceNode
        self.perform = perform
    }

    // MARK: - Computed Properties and Functions

    func arrange(items: [HistoryItem], direction: Direction) {
        for entry in consolidate(items: items, direction: direction) {
            perform(entry.value, entry.key)
        }
    }

    func consolidate(items: [HistoryItem], direction: Direction) -> MoveTable {
        var result: MoveTable = [:]

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
            if let candidate = getPieceNode(square) {
                return candidate
            }
            fatalError("Unable to find a pieceNode at \(square.description)")
        }

        func consolidate(item: HistoryItem) {

            let pieceNode = findNode(for: direction.isRedo ? item.move.origin : item.move.target)

            var transaction: Transaction = {

                let move = direction.isUndo ? item.move.reversed() : item.move

                if var candidate = result[pieceNode] {
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
                    result.updateValue(transaction, forKey: pieceNode)
                case .undo:
                    let capturedNode = newPieceNode(capture.piece)
                    result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .added)
                }
            }

            if let promotion = item.promotion {
                // In either direction, the pieceNode is removed and a new piece is added, either a pawn or the chosen promotion.
                transaction.status = .removed
                let piece = direction.isRedo ? promotion : Piece(pawn: promotion.color)
                let move = direction.isRedo ? item.move : item.move.reversed()
                result[newPieceNode(piece)] = Transaction(origin: move.origin, target: move.target, status: .added)
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
            result[pieceNode] = transaction
        }

        let elements = direction.isRedo ? items : items.reversed()
        elements.forEach(consolidate)
        return result
    }

}
