//
//  NodeType.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

enum NodeType {

    case square
    case piece
    case arrow

    var zPosition: CGFloat {
        switch self {
        case .square: return 100
        case .piece: return 400
        case .arrow: return 200
        }
    }
}

final class PieceNode: SKSpriteNode { }

