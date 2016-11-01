//
//  UserActivityCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/19/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

protocol UserActivityDelegate {
    func userDidBeginActivity(on origin: Square)
    func userDidPan(to square: Square)
    func userDidEndActivity(with move: Move, for pieceNode: PieceNode)
    func userDidNormalizeActivity()
}

typealias Execution = (Move, Piece?) -> Void

final class UserActivityCoordinator: UserActivityDelegate {

    private let game: Game
    private let pieceModel: PieceNodeModel
    private let arrowModel: ArrowNodeModel
    private let squareModel: SquareNodeModel
    private let presentingViewController: UIViewController

    init(game: Game, pieceModel: PieceNodeModel, arrowModel: ArrowNodeModel, squareModel: SquareNodeModel, presentingViewController: UIViewController) {
        self.game = game
        self.pieceModel = pieceModel
        self.arrowModel = arrowModel
        self.squareModel = squareModel
        self.presentingViewController = presentingViewController
    }

    private var _availableTargets: [Square] = [] {
        didSet {
            squareModel.presentSquareNodes(for: _availableTargets, ofType: .target)
        }
    }

    private var _availableCaptures: [Square] = [] {
        didSet {
            squareModel.presentSquareNodes(for: _availableCaptures, ofType: .capture)
        }
    }

    func userDidBeginActivity(on origin: Square) {
        arrowModel.removeArrows(with: .lastMove)
        squareModel.presentSquareNodes(for: [origin], ofType: .origin)
        _availableTargets = game.availableTargets(forPieceAt: origin)
        _availableCaptures = game.availableCaptures(forPieceAt: origin)
    }

    func userDidPan(to candidate: Square) {
        squareModel.presentSquareNodes(for: [candidate], ofType: .candidate)
    }

    func userDidEndActivity(with move: Move, for pieceNode: PieceNode) {

        var target = move.target
        if !_availableTargets.contains(move.target) {
            target = move.origin
        }

        if target == move.origin {
            pieceModel.move(pieceNode, to: target)
            return
        }

        if let capturedNode = pieceModel.pieceNode(for: target, excepting: pieceNode) {
            capturedNode.zPosition = pieceNode.zPosition - 1
            capturedNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                self.pieceModel.capture(capturedNode)
            }
        }

        if move.isCastle() {
            let (old, new) = move.castleSquares()
            guard let rookNode = pieceModel.pieceNode(for: old) else {
                fatalError("Expected a rook at \(old.description)")
            }
            pieceModel.move(rookNode, to: new)
        }

        pieceModel.move(pieceNode, to: target)

        let piece = pieceNode.piece()
        let isPromotion = piece.kind.isPawn && move.target.rank == Rank.init(endFor: piece.color)

        if isPromotion {
            let vc = UIStoryboard.main.instantiate(PromotionViewController.self)
            vc.color = piece.color
            vc.completion = { promotion in
                self.pieceModel.remove(pieceNode)
                self.pieceModel.add(self.pieceModel.pieceNode(for: promotion), at: move.target)
                do {
                    try self.game.execute(move: move, promotion: promotion)
                } catch {
                    fatalError("Could not execute move \(move) with promotion: \(promotion)")
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            presentingViewController.present(vc, animated: true)
        } else {
            do {
                try game.execute(move: move)
            } catch {
                fatalError("Could not execute move")
            }
        }
    }

    func userDidNormalizeActivity() {

        squareModel.clearSquareNodes(ofType: .origin)
        squareModel.clearSquareNodes(ofType: .candidate)
        _availableCaptures = []
        _availableTargets = []
        
        arrowModel.removeArrows(with: .lastMove)
        if let move = game.latestMove {
            let lastMoveArrow = arrowModel.arrowNode(for: move, with: .lastMove)
            arrowModel.add(lastMoveArrow)
        }

        presentCheckingArrows()
        presentAllAvailableSquares()
        presentAllDefendedSquares()

    }

    // MARK: - Private // MARK: - Private Computed Properties and Functions

    private func presentCheckingArrows() {
        arrowModel.removeArrows(with: .check)
        let checks = game.squaresAttackingKing
        if checks.isEmpty { return }
        for move in game.movesAttackingKing() {
            let arrow = arrowModel.arrowNode(for: move, with: .check)
            arrowModel.add(arrow)
        }
    }

    private func presentAllAvailableSquares() {
        squareModel.clearSquareNodes(ofType: .available)
        let squares = game.availableTargets(for: game.playerTurn)
        for square in squares {
            let node = squareModel.squareNode(with: square, ofType: .available)
            squareModel.add(node)            
        }
    }

//    private func presentAllAttackingSquares() {
//
//    }

    private func presentAllDefendedSquares() {
        squareModel.clearSquareNodes(ofType: .defended)
        let squares = game.defendedOccupations(for: game.playerTurn)
        for square in squares {
            let node = squareModel.squareNode(with: square, ofType: .defended)
            node.zPosition += 10
            squareModel.add(node)
        }
    }

}
