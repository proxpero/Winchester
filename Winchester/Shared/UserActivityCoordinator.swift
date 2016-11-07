//
//  UserActivityCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/19/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

typealias Execution = (Move, Piece?) -> Void

final class UserActivityCoordinator {

    private let game: Game
    private let pieceNodeDataSource: PieceNodeDataSource
    private let arrowNodeDataSource: ArrowNodeDataSource
    private let squareNodeDataSource: SquareNodeDataSource
    private weak var presentingViewController: UIViewController?

    init(game: Game, pieceNodeDataSource: PieceNodeDataSource, arrowNodeDataSource: ArrowNodeDataSource, squareNodeDataSource: SquareNodeDataSource, presentingViewController: UIViewController) {
        self.game = game
        self.pieceNodeDataSource = pieceNodeDataSource
        self.arrowNodeDataSource = arrowNodeDataSource
        self.squareNodeDataSource = squareNodeDataSource
        self.presentingViewController = presentingViewController
    }

    private var _availableTargets: [Square] = [] {
        didSet {
            squareNodeDataSource.presentSquareNodes(for: _availableTargets, ofKind: .target)
        }
    }

    private var _availableCaptures: [Square] = [] {
        didSet {
            squareNodeDataSource.presentSquareNodes(for: _availableCaptures, ofKind: .capture)
        }
    }

    func userDidBeginActivity(on origin: Square) {
        arrowNodeDataSource.removeArrows(with: .lastMove)
        squareNodeDataSource.presentSquareNodes(for: [origin], ofKind: .origin)
        _availableTargets = game.availableTargets(forPieceAt: origin)
        _availableCaptures = game.availableCaptures(forPieceAt: origin)
    }

    func userDidMovePiece(to candidate: Square) {
        squareNodeDataSource.presentSquareNodes(for: [candidate], ofKind: .candidate)
    }

    func userDidEndActivity(with move: Move, for pieceNode: Piece.Node) {

        var target = move.target
        if !_availableTargets.contains(move.target) {
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

        if isPromotion {
            let vc = UIStoryboard.main.instantiate(PromotionViewController.self)
            vc.color = piece.color
            vc.completion = { promotion in
                self.pieceNodeDataSource.remove(pieceNode)
                self.pieceNodeDataSource.add(self.pieceNodeDataSource.pieceNode(for: promotion), at: move.target)
                do {
                    try self.game.execute(move: move, promotion: promotion)
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

    func userDidNormalizeActivity() {

        squareNodeDataSource.clearSquareNodes(ofKind: .origin)
        squareNodeDataSource.clearSquareNodes(ofKind: .candidate)
        _availableCaptures = []
        _availableTargets = []
        
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
        arrowNodeDataSource.removeArrows(with: .check)
        let checks = game.squaresAttackingKing
        if checks.isEmpty { return }
        for move in game.movesAttackingKing() {
            let arrow = arrowNodeDataSource.arrowNode(for: move, with: .check)
            arrowNodeDataSource.add(arrow)
        }
    }

    private func presentAllAvailableSquares() {
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
        squareNodeDataSource.clearSquareNodes(ofKind: .defended)
        let squares = game.defendedOccupations(for: game.playerTurn)
        for square in squares {
            let node = squareNodeDataSource.squareNode(with: square, ofKind: .defended)
            node.zPosition += 10
            squareNodeDataSource.add(node)
        }
    }

}
