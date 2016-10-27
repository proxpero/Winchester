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
    func userDidEndActivity(with move: Move, for pieceNode: PieceNode)
    func userDidNormalizeActivity()
    func userDidPromote(with color: Color) -> Piece?
    func userDidExecute(move: Move, promotion: Piece?)
    
}

final class UserActivityCoordinator: UserActivityDelegate {

    private let game: Game
    private let pieceModel: PieceNodeModel
    private let arrowModel: ArrowNodeModel
    private let squareModel: SquareNodeModel

    init(game: Game, pieceModel: PieceNodeModel, arrowModel: ArrowNodeModel, squareModel: SquareNodeModel) {
        self.game = game
        self.pieceModel = pieceModel
        self.arrowModel = arrowModel
        self.squareModel = squareModel
    }

    func userDidBeginActivity(on origin: Square) {

        squareModel.presentSquareNodes(for: game.availableTargets(forPieceAt: origin), ofType: .attacked)
        squareModel.presentSquareNodes(for: game.availableCaptures(forPieceAt: origin), ofType: .capture)

    }

    func userDidEndActivity(with move: Move, for pieceNode: PieceNode) {
        // test for promotion

    }

    func userDidNormalizeActivity() {

        squareModel.clearSquareNodes(ofType: .attacked)
        squareModel.clearSquareNodes(ofType: .capture)
        // test for check (show arrows, covergage, attacks by most recent move)



        presentLastMoveArrow()
        presentCheckingArrows()
        presentAllAvailableSquares()
        presentAllDefendedSquares()

    }

    func userDidPromote(with color: Color) -> Piece? {
        return nil
    }

    func userDidExecute(move: Move, promotion: Piece?) {

    }

    // MARK: - Private // MARK: - Private Computed Properties and Functions

    private func presentLastMoveArrow() {
        arrowModel.removeArrows(with: .lastMove)
        guard let move = game.latestMove else { return }
        let arrow = arrowModel.arrowNode(for: move, with: .lastMove)
        arrowModel.add(arrow)
    }

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

    private func presentAllAttackingSquares() {

    }

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
