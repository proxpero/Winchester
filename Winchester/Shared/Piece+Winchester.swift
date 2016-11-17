//
//  Piece+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

extension Piece {

    final class Node: SKSpriteNode {

        init(piece: Piece, size: CGSize) {
            let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
            super.init(
                texture: SKTexture(imageNamed: imageName),
                color: .clear,
                size: size)
            name = String(piece.character)
            zPosition = NodeType.piece.zPosition
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func piece() -> Piece {
            guard
                let name = name,
                let char = name.characters.first,
                let piece = Piece(character: char)
                else { fatalError() }
            return piece
        }

    }

}
