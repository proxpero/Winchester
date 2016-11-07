//
//  UserInteraction+BoardViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

protocol BoardViewDelegateType: BoardViewDelegate {

    weak var game: Game? { get set }

    var pieceNodeDataSource: PieceNodeDataSource { get }
    var squareNodeDataSource: SquareNodeDataSource { get }
    var arrowNodeDataSource: ArrowNodeDataSource { get }

    weak var presentingViewController: ViewController? { get }

    var _availableTargetsCache: [Square] { get set }
    var _availableCapturesCache: [Square] { get set }
    
}

extension BoardViewDelegateType {

    mutating func _setAvailableTargets(_ newTargets: [Square]) {
        _availableTargetsCache = newTargets
        squareNodeDataSource.presentSquareNodes(for: _availableTargetsCache, ofKind: .target)
    }

    mutating func _setAvailableCaptures(_ newCaptures: [Square]) {
        _availableCapturesCache = newCaptures
        squareNodeDataSource.presentSquareNodes(for: newCaptures, ofKind: .capture)
    }

    mutating func didBeginActivity(on origin: Square) {
        guard let game = game else { fatalError("Expected a game") }
        arrowNodeDataSource.removeArrows(with: .lastMove)
        squareNodeDataSource.presentSquareNodes(for: [origin], ofKind: .origin)
        _setAvailableTargets(game.availableTargets(forPieceAt: origin))
        _setAvailableCaptures(game.availableCaptures(forPieceAt: origin))
    }

    func didMovePiece(to candidate: Square) {
        squareNodeDataSource.presentSquareNodes(for: [candidate], ofKind: .candidate)
    }

    func didEndActivity(with move: Move, for pieceNode: Piece.Node) {

        var target = move.target
        if !_availableTargetsCache.contains(move.target) {
            target = move.origin
        }

        if target == move.origin {
            pieceNodeDataSource.move(pieceNode, to: target)
            return
        }

        if let capturedNode = pieceNodeDataSource.pieceNode(for: target, excepting: pieceNode) {
            capturedNode.zPosition = pieceNode.zPosition - 1
            capturedNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                self.pieceNodeDataSource.capture(capturedNode)
            }
        }

        if move.isCastle() {
            let (old, new) = move.castleSquares()
            guard let rookNode = pieceNodeDataSource.pieceNode(for: old) else {
                fatalError("Expected a rook at \(old.description)")
            }
            pieceNodeDataSource.move(rookNode, to: new)
        }

        pieceNodeDataSource.move(pieceNode, to: target)

        let piece = pieceNode.piece()
        let isPromotion = piece.kind.isPawn && move.target.rank == Rank.init(endFor: piece.color)

        guard let game = game else { fatalError("Expected a game") }

        if isPromotion {
            // WARNING: UIKit Dependency
            let vc = UIStoryboard.main.instantiate(PromotionViewController.self)
            vc.color = piece.color
            vc.completion = { promotion in
                self.pieceNodeDataSource.remove(pieceNode)
                self.pieceNodeDataSource.add(self.pieceNodeDataSource.pieceNode(for: promotion), at: move.target)
                do {
                    try game.execute(move: move, promotion: promotion)
                } catch {
                    fatalError("Could not execute move \(move) with promotion: \(promotion)")
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            presentingViewController?.present(vc, animated: true)
        } else {
            do {
                try game.execute(move: move)
            } catch {
                fatalError("Could not execute move")
            }
        }
    }

    mutating func didNormalizeActivity() {
        guard let game = game else { fatalError("Expected a game") }

        squareNodeDataSource.clearSquareNodes(ofKind: .origin)
        squareNodeDataSource.clearSquareNodes(ofKind: .candidate)
        _setAvailableCaptures([])
        _setAvailableTargets([])

        arrowNodeDataSource.removeArrows(with: .lastMove)
        if let move = game.latestMove {
            let lastMoveArrow = arrowNodeDataSource.arrowNode(for: move, with: .lastMove)
            arrowNodeDataSource.add(lastMoveArrow)
        }

        presentCheckingArrows()
        presentAllAvailableSquares()
        presentAllDefendedSquares()

    }

    // MARK: - Private // MARK: - Private Computed Properties and Functions

    private func presentCheckingArrows() {
        guard let game = game else { fatalError("Expected a game") }

        arrowNodeDataSource.removeArrows(with: .check)
        let checks = game.squaresAttackingKing
        if checks.isEmpty { return }
        for move in game.movesAttackingKing() {
            let arrow = arrowNodeDataSource.arrowNode(for: move, with: .check)
            arrowNodeDataSource.add(arrow)
        }
    }

    private func presentAllAvailableSquares() {
        guard let game = game else { fatalError("Expected a game") }

        squareNodeDataSource.clearSquareNodes(ofKind: .available)
        let squares = game.availableTargets(for: game.playerTurn)
        for square in squares {
            let node = squareNodeDataSource.squareNode(with: square, ofKind: .available)
            squareNodeDataSource.add(node)
        }
    }

    //    private func presentAllAttackingSquares() {
    //
    //    }

    private func presentAllDefendedSquares() {
        guard let game = game else { fatalError("Expected a game") }

        squareNodeDataSource.clearSquareNodes(ofKind: .defended)
        let squares = game.defendedOccupations(for: game.playerTurn)
        for square in squares {
            let node = squareNodeDataSource.squareNode(with: square, ofKind: .defended)
            node.zPosition += 10
            squareNodeDataSource.add(node)
        }
    }
    
}
