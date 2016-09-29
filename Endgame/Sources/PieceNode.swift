//
//  PieceNode.swift
//  Endgame
//
//  Created by Todd Olsen on 8/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

final public class PieceNode: SKSpriteNode {

    init(piece: Piece, with size: CGSize) {
        let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
        super.init(texture: SKTexture(imageNamed: imageName), color: .clear, size: size)
        self.name = piece.description
        self.zPosition = 20
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
