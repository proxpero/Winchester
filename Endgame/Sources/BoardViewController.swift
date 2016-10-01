//
//  BoardViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

#if os(OSX)
    import Cocoa
    typealias ViewController = NSViewController
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias ViewController = UIViewController
#endif

import Engine
import SpriteKit

internal final class BoardViewController: ViewController {

    typealias MoveTable = Dictionary<PieceNode, Transaction>

    struct Transaction {
        var origin: Square
        var target: Square
        var isAdded: Bool
        var isRemoved: Bool
    }

    func arrange(items: [HistoryItem], direction: Direction) {
        for (pieceNode, transaction) in items.reduce(MoveTable(), consolidate(in: direction)) {
            pieceNode.run(SKAction.move(to: _scene.piecesLayer.position(for: transaction.target), duration: 0.2))
            if transaction.isRemoved {
                pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                    self._scene.piecesLayer.removeFromParent()
                }
            }
            if transaction.isAdded {
                _scene.piecesLayer.addChild(pieceNode)
                pieceNode.alpha = 0.0
                pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
            }

        }
    }

    func consolidate(in direction: Direction) -> (MoveTable, HistoryItem) -> MoveTable {
        switch direction {
        case .forward(_):
            return forwardConsolidation
        case .reverse(_):
            return reverseConsolidation
        case .none:
            fatalError()
        }
    }

    private func forwardConsolidation(entries: MoveTable, item: HistoryItem) -> MoveTable {
        var result = entries

        guard let pieceNode = self[item.move.origin] else {
            print("ERROR: Could not find a piece at \(item.move.origin)\nsanMove: \(item.sanMove), \(item)")
            return entries
        }

        // If a capture is involved then the pieceNode of the captured piece must be removed.
        if let capture = item.capture {
            guard let capturedNode = self[capture.square] else {
                fatalError("I was expecting a piece to capture on \(capture.square.description)")
            }
            if var captureTransaction = result[capturedNode] {
                captureTransaction.isRemoved = true
                result[capturedNode] = captureTransaction
            } else {
                result[capturedNode] = Transaction(origin: capture.square, target: capture.square, isAdded: false, isRemoved: true)
            }
        }

        var transaction = result[pieceNode] ?? Transaction(origin: item.move.origin, target: item.move.target, isAdded: false, isRemoved: false)

        // If a promotion is involved then the current pieceNode will be replaced
        // and a new piece will be introduced.
        if let promotion = item.promotion {
            transaction.target = item.move.target
            transaction.isRemoved = true
            result[pieceNode] = transaction
            result[newPieceNode(for: promotion)] = Transaction(origin: item.move.origin, target: item.move.target, isAdded: true, isRemoved: false)
            return result
        }

        // If a castle is involved then the rook need to be moved and added to the table.
        if item.move.isCastle() {
            let (old, new) = item.move.castleSquares()
            guard let rookNode = self[old] else { fatalError("I was expecting a rook at \(old.description)") }
            result[rookNode] = Transaction(origin: old, target: new, isAdded: false, isRemoved: false)
        }

        transaction.target = item.move.target
        result[pieceNode] = transaction

        return result
    }

    private func reverseConsolidation(entries: MoveTable, item: HistoryItem) -> MoveTable {
        var result = entries

        guard let pieceNode = self[item.move.target] else {
            fatalError("Where should the piecenode be? at the origin?")
        }

        // If a capture is involved then the captured piece needs 
        // to be added.
        if let capture = item.capture {
            let capturedNode = newPieceNode(for: capture.piece)
            result[capturedNode] = Transaction(origin: capture.square, target: capture.square, isAdded: true, isRemoved: false)
        }

        var transaction = result[pieceNode] ?? Transaction(origin: item.move.target, target: item.move.origin, isAdded: false, isRemoved: false)

        // If a promotion is involved then the current pieceNode will be replaced and a new piece (a pawn) will be introduced.
        if let promotion = item.promotion {
            transaction.target = item.move.origin
            transaction.isRemoved = true
            result[pieceNode] = transaction
            result[newPieceNode(for: Piece(pawn: promotion.color))] = Transaction(origin: item.move.target, target: item.move.origin, isAdded: true, isRemoved: false)
            return result
        }

        if item.move.isCastle() {
            let (new, old) = item.move.castleSquares()
            guard let rookNode = self[old] else { fatalError("I was exapecting a rook at \(old.description)") }
            var rookTransaction = result[rookNode] ?? Transaction(origin: new, target: new, isAdded: false, isRemoved: false)
            rookTransaction.target = new
            result[rookNode] = rookTransaction
        }

        return result
    }

    func perform(item: HistoryItem, direction: Direction) {
        let move = direction.isForward ? item.move : item.move.reversed()

        var endPiece: Piece? = nil
        if let promotion = item.promotion {
            if direction.isReverse {
                endPiece = Piece(pawn: promotion.color)
            } else {
                endPiece = promotion
            }
        }
        _scene.perform(move: move, endPiece: endPiece)

        if item.move.isCastle() {
            let (rookOrigin, rookTarget) = item.move.castleSquares()
            let rookMove: Move
            if direction.isForward {
                rookMove = Move(origin: rookOrigin, target: rookTarget)
            } else {
                rookMove = Move(origin: rookTarget, target: rookOrigin)
            }
            _scene.perform(move: rookMove)
        }

        if let capture = item.capture {
            if direction.isReverse {
                _scene.replace(capture: capture)
            } else {
                _scene.remove(capture: capture)
            }
        }
    }

    // MARK: - Activity

    enum ActivityState {
        case initiation(Square)
        case end(origin: Square, target: Square)
        case normal
    }

    internal var activityState: ActivityState = .normal {
        didSet {
            switch activityState {
            case .initiation(let origin):
                beginActivity(for: origin)
            case .end(let origin, let target):
                endActivity(with: origin, target: target)
            case .normal:
                normalizeActivity()
            }
        }
    }

    func beginActivity(for origin: Square) {
//        let squareNodes = _scene.squaresLayer.squareNodes(for: availableMoves(origin))
//        for squareNode in squareNodes {
//            squareNode.highlightType = .available
//        }
    }

    func normalizeActivity() {
        _scene.squaresLayer.removeHighlights()
    }

    func endActivity(with origin: Square, target: Square?) {

//        defer {
//            activityState = .normal
//        }
//
//        guard let target = target, availableMoves(origin).contains(target) else {
//            // move piece back to origin
//            return
//        }
//
//        guard execute(Move(origin: origin, target: target)) else {
//            fatalError("Error: no handling in \(#function)")
//        }
//        _scene.piecesLayer.movePiece(from: origin, to: target, animated: true)
    }

    override func viewDidLayoutSubviews() {
        guard let skview = view as? SKView else { return }
        let scene = GameScene(edge: view.bounds.width)
        skview.presentScene(scene)
    }

    private var _scene: GameScene {
        guard
            let skview = view as? SKView,
            let scene = skview.scene as? GameScene
            else { fatalError("") }
        return scene
    }

    subscript(square: Square) -> PieceNode? {
        get {
            return _scene.piecesLayer.node(for: square)
        }
    }

    internal func newPieceNode(for piece: Piece) -> PieceNode {
        return _scene.piecesLayer.pieceNode(for: piece)
    }

    internal func place(_ pieceNode: PieceNode, on square: Square) {
        pieceNode.alpha = 0.0
        _scene.piecesLayer.addChild(pieceNode)
        pieceNode.position = _scene.piecesLayer.position(for: square)
        pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
    }

    internal func remove(_ pieceNode: PieceNode) {
        pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
            pieceNode.removeFromParent()
        }
    }

    internal func move(_ pieceNode: PieceNode, to square: Square) {
        pieceNode.run(SKAction.move(to: _scene.piecesLayer.position(for: square), duration: 0.2))
    }

}

protocol GameSceneDataSource {

    func piece(_: GameScene, at square: Square) -> Piece
}
