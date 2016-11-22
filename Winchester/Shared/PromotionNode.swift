//
//  PromotionNode.swift
//  Winchester
//
//  Created by Todd Olsen on 11/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

public protocol PromotionNodeProtocol {
    func presentPromotion(for color: Color, completion: @escaping (Piece) -> Void)
}

public enum PromotionType: Int {
    case queen
    case rook
    case bishop
    case knight

    func piece(for color: Color) -> Piece {
        switch  self {
        case .queen: return Piece(queen: color)
        case .rook: return Piece(rook: color)
        case .bishop: return Piece(bishop: color)
        case .knight: return Piece(knight: color)
        }
    }
}

public final class PromotionNode: SKSpriteNode {

    private let queenNode: Piece.Node
    private let rookNode: Piece.Node
    private let bishopNode: Piece.Node
    private let knightNode: Piece.Node

    private let completion: (Piece) -> Void
    private let promotingColor: Color

    public init(color: Color,  size: CGSize, completion: @escaping (Piece) -> Void) {
        self.promotingColor = color
        self.completion = completion

        let inset = CGSize(width: size.width*0.9, height: size.height*0.9)
        let pieceSize = CGSize(width: inset.width/4, height: inset.height/4)
        self.queenNode = Piece.Node(piece: Piece(queen: color), size: pieceSize)
        self.rookNode = Piece.Node(piece: Piece(rook: color), size: pieceSize)
        self.bishopNode = Piece.Node(piece: Piece(bishop: color), size: pieceSize)
        self.knightNode = Piece.Node(piece: Piece(knight: color), size: pieceSize)


        super.init(texture: nil, color: .clear, size: size)

        addChild(queenNode)
        addChild(rookNode)
        addChild(bishopNode)
        addChild(knightNode)

        let offset = inset.width/4.0
        queenNode.position = CGPoint(x: position.x-offset, y: position.y+offset)
        rookNode.position = CGPoint(x: position.x+offset, y: position.y+offset)
        bishopNode.position = CGPoint(x: position.x-offset, y: position.y-offset)
        knightNode.position = CGPoint(x: position.x+offset, y: position.y-offset)

        queenNode.zPosition = zPosition + 10
        rookNode.zPosition = zPosition + 10
        bishopNode.zPosition = zPosition + 10
        knightNode.zPosition = zPosition + 10

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch = touches.first,
            let node = [queenNode, rookNode, bishopNode, knightNode].filter({ $0.contains(touch.location(in: self)) }).first
            else { return }
        let promotion = node.piece()
        completion(promotion)
        self.run(SKAction.fadeOut(withDuration: 0.2)) {
            self.removeFromParent()
        }
    }

}
