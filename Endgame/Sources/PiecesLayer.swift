//
//  PiecesLayer.swift
//  Endgame
//
//  Created by Todd Olsen on 10/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

public typealias PieceNode = SKSpriteNode

public final class PiecesLayer: SKSpriteNode, GameLayer {

    typealias NodeType = PieceNode

    public func pieceNode(for piece: Piece) -> PieceNode {

        let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
        let pieceNode = PieceNode(
            texture: SKTexture(imageNamed: imageName),
            color: .clear,
            size: squareSize
        )

        pieceNode.name = String(piece.character)
        pieceNode.zPosition = 210

        return pieceNode
    }

    public func setupPieces(for board: Board) {
        for space in board {
            if let piece = space.piece {
                let node = self.pieceNode(for: piece)
                node.position = position(for: space.square)
                addChild(node)
            }
        }
    }

    func perform(_ transaction: Transaction, on pieceNode: PieceNode) {
        if transaction.status == .removed {
            pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                pieceNode.removeFromParent()
            }
        } else {
            if transaction.status == .added {
                pieceNode.alpha = 0.0
                pieceNode.position = position(for: transaction.origin)
                addChild(pieceNode)
                pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
            }
            pieceNode.run(SKAction.move(to: position(for: transaction.target), duration: 0.2))
        }
    }
}
