//
//  BoardViewDelegateType.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

public protocol BoardViewDelegateType: class, BoardViewDelegate {

    weak var game: Game? { get }
    var availableTargetsCache: [Square] { get set }

}

extension BoardViewDelegateType {

    public func boardView(_ boardView: BoardViewType, didBeginActivityOn origin: Square) {
        guard let game = game else { return }

        availableTargetsCache = game.availableTargets(forPieceAt: origin)
        boardView.removeArrows(with: .lastMove)
        boardView.present([origin], as: .origin)
        boardView.present(availableTargetsCache, as: .target)
        boardView.present(game.availableCaptures(forPieceAt: origin), as: .capture)
    }

    public func boardViewDidNormalizeActivity(_ boardView: BoardViewType) {
        guard let game = game else { fatalError("ERROR: expected a game.") }
        availableTargetsCache = []
        boardView.clearSquareNodes()
        let lastMove: [Move] = game.latestMove == nil ? [] : [game.latestMove!]
        boardView.presentArrows(for: lastMove, ofKind: .lastMove)
        
        boardView.presentArrows(for: game.movesAttackingKing(), ofKind: .check)
        //        boardView.present(<#T##squares: [Square]##[Square]#>, as: .available)
        //        boardView.present(<#T##squares: [Square]##[Square]#>, as: .defended)
    }

    public func boardView(_ boardView: BoardViewType, didMovePieceTo square: Square) {
        boardView.present([square], as: .candidate)
    }

    public func boardView(_ boardView: BoardViewType, didEndActivityWith move: Move, for pieceNode: Piece.Node) {

        var target = move.target
        if !availableTargetsCache.contains(move.target) {
            target = move.origin
        }

        if target == move.origin {
            boardView.move(pieceNode, to: target)
            return
        }

        if let capturedNode = boardView.pieceNode(for: target, excepting: pieceNode) {
            capturedNode.zPosition = pieceNode.zPosition - 1
            capturedNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                boardView.capture(capturedNode)
            }
        }

        if move.isCastle() {
            let (old, new) = move.castleSquares()
            guard let rookNode = boardView.pieceNode(for: old) else {
                fatalError("Expected a rook at \(old.description)")
            }
            boardView.move(rookNode, to: new)
        }

        boardView.move(pieceNode, to: target)

        let piece = pieceNode.piece()
        let isPromotion = piece.kind.isPawn && move.target.rank == Rank.init(endFor: piece.color)

        guard let game = game else { fatalError("Expected a game") }

        if isPromotion {
            boardView.presentPromotion(for: piece.color) { promotion in
                do {
                    try game.execute(move: move, promotion: promotion)
                } catch {
                    fatalError("Could not execute move \(move) with promotion: \(promotion)")
                }
            }
        } else {
            do {
                try game.execute(move: move)
            } catch {
                fatalError("Could not execute move")
            }
        }
    }
    
}
