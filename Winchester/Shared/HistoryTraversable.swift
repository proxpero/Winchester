//
//  HistoryTraversable.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

public protocol HistoryTraversable {
    func traverse(_ items: [HistoryItem], in direction: Direction)
}

// An object to encapsulate what needs to happen to each piece.
private struct Transaction {
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

extension HistoryTraversable where Self: BoardViewProtocol, Self: PieceNodeDataSource, Self: PieceNodeCaptureProtocol {

    public func traverse(_ items: [HistoryItem], in direction: Direction) {

        typealias TransactionTable = Dictionary<Piece.Node, Transaction>

        // Create a table of the pieceNodes that are affected by the change and their origins and final resting places.
        func consolidate(_ items: [HistoryItem], in direction: Direction) -> TransactionTable {
            var result: TransactionTable = [:]

            func findNode(for square: Square) -> Piece.Node {
                // If the pieceNode has been moved already
                func node(at square: Square) -> Piece.Node? {
                    let nodes = result
                        .filter { $0.value.target == square && !$0.value.status.isRemoved() }
                        .map { $0.key }
                    guard nodes.count == 1 else { return nil }
                    return nodes[0]
                }
                if let candidate = node(at: square) {
                    return candidate
                }
                if let candidate = pieceNode(for: square) {
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
                        let capturedNode = pieceNode(for: capture.piece)
                        result[capturedNode] = Transaction(origin: capture.square, target: capture.square, status: .resurrected)
                    }
                }

                if let promotion = item.promotion {
                    // In either direction, the pieceNode is removed and a new piece is added, either a pawn or the chosen promotion.
                    transaction.status = .removed
                    let piece = direction.isRedo ? promotion : Piece(pawn: promotion.color)
                    let move = direction.isRedo ? item.move : item.move.reversed()
                    result[pieceNode(for: piece)] = Transaction(origin: move.origin, target: move.target, status: .added)
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

        func perform(_ transaction: Transaction, on pieceNode: Piece.Node) {
            if transaction.status == .removed {
                remove(pieceNode)
            } else if transaction.status == .captured {
                capture(pieceNode)
            } else {
                if transaction.status == .added {
                    add(pieceNode, at: transaction.origin)
                } else if transaction.status == .resurrected {
                    resurrect(pieceNode, at: transaction.origin)
                }
                move(pieceNode, to: transaction.target)
            }
            
        }

        // Move each piece in the transaction table to its right place.
        for (pieceNode, transaction) in consolidate(items, in: direction) {
            // Add, remove, or move the piece based on its transaction.
            perform(transaction, on: pieceNode)
        }
    }
    
}
