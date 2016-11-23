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

public final class PromotionNode: SKSpriteNode {

    private let pieceColor: Color
    private let completion: (Piece) -> Void

    public init(pieceColor: Color, background: SKTexture, completion: @escaping (Piece) -> Void) {
        self.pieceColor = pieceColor
        self.completion = completion
        super.init(texture: background, color: .clear, size: background.size())
        zPosition = 900
        setupPieceNodes()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPieceNodes() {

        let inset = CGSize(width: size.width*0.8, height: size.height*0.8)
        let pieceSize = CGSize(width: inset.width/4, height: inset.height/4)
        let offset = inset.width/6.0

        let pieces = [
            Piece.Kind.queen,
            Piece.Kind.rook,
            Piece.Kind.bishop,
            Piece.Kind.knight
        ]

        let positions = [
            CGPoint(x: position.x-offset, y: position.y+offset),
            CGPoint(x: position.x+offset, y: position.y+offset),
            CGPoint(x: position.x-offset, y: position.y-offset),
            CGPoint(x: position.x+offset, y: position.y-offset)
        ]

        let sequence = zip(pieces.map { Piece(kind: $0, color: pieceColor) }, positions)

        for (piece, position) in sequence {
            let node = Piece.Node(piece: piece, size: pieceSize)
            node.position = position
            node.zPosition = zPosition + 20
            addChild(node)
        }
        
    }

    func handlePromotion(_ recognizer: UITapGestureRecognizer) {
        guard let scene = scene, let view = scene.view as? BoardView else { return }
        let location = scene.convertPoint(fromView: recognizer.location(in: view))
        for pieceNode in children.flatMap({ $0 as? Piece.Node }) {
            if pieceNode.contains(location) {
                let promotion = pieceNode.piece()
                completion(promotion)
                run(SKAction.fadeOut(withDuration: 0.2)) {
                    self.removeFromParent()
                }
                return
            }
        }
    }
}

