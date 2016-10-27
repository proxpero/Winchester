//
//  SquareNode.swift
//  Winchester
//
//  Created by Todd Olsen on 10/26/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

enum SquareType: Equatable {

    case normal(Square)
    case target
    case capture
    case defended
    case attacked
    case available
    case aggressive

    var texture: SKTexture? {
        switch self {
        case .normal(let square): return square.color.isWhite ? SKTexture(image: #imageLiteral(resourceName: "LightSquare")) : SKTexture(image: #imageLiteral(resourceName: "DarkSquare"))
        case .target: return SKTexture(image: #imageLiteral(resourceName: "AvailableSquare"))
        case .capture: return SKTexture(image: #imageLiteral(resourceName: "AttackedSquare"))
        default: return nil
        }
    }

    static func == (lhs: SquareType, rhs: SquareType) -> Bool {
        switch (lhs, rhs) {
        case (.normal(let left), .normal(let right)):
            return left == right
        case (.target, .target): return true
        case (.capture, .capture): return true
        case (.defended, .defended): return true
        case (.attacked, .attacked): return true
        case (.available, .available): return true
        case (.aggressive, .aggressive): return true
        default: return false
        }
    }
}

final class SquareNode: SKSpriteNode {

    let type: SquareType

    init(type: SquareType) {
        self.type = type

        let color: UIColor
        switch type {
        case .defended:
            color = UIColor(red: 0.6, green: 0.6, blue: 0.9, alpha: 0.35)
        case .available: color = UIColor(red: 0.9, green: 0.9, blue: 0.6, alpha: 0.3)
        default: color = .clear
        }

        super.init(texture: type.texture, color: color, size: CGSize.zero)
        self.zPosition = NodeType.square.zPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
