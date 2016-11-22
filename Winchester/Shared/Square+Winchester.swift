//
//  Square+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

extension Square {

    public final class Node: SKSpriteNode {

        public let kind: Kind

        public init(kind: Kind, for square: Square) {
            self.kind = kind
            super.init(texture: kind.texture(for: square), color: kind.color(for: square), size: CGSize.zero)
            self.zPosition = kind.zPosition
            self.name = square.description
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

    public enum Kind {

        case normal
        case origin
        case candidate
        case target
        case capture
        case defended
        case attacked
        case available
        case aggressive

        static var decorators: [Kind] = [.origin, .candidate, .target, .capture, .defended, .attacked, .available, .aggressive]
        static var all: [Kind] = Kind.decorators + [.normal]

        func texture(for square: Square) -> SKTexture? {
            switch self {
            case .normal:
                return square.color.isWhite ? SKTexture(image: #imageLiteral(resourceName: "LightSquare")) : SKTexture(image: #imageLiteral(resourceName: "DarkSquare"))
            case .target: return SKTexture(image: #imageLiteral(resourceName: "AvailableSquare"))
            case .capture: return SKTexture(image: #imageLiteral(resourceName: "AttackedSquare"))
            default: return nil
            }
        }

        func color(for square: Square) -> UIColor {
            switch self {
            case .origin:
                switch square.color {
                case .white: return UIColor(white: 0.3, alpha: 0.4)
                case .black: return UIColor(white: 0.2, alpha: 0.5)
                }
            case .candidate: return UIColor.white // return UIColor(red: 0.3, green: 0.3, blue: 0.7, alpha: 0.5)
            case .defended: return UIColor(red: 0.6, green: 0.6, blue: 0.9, alpha: 0.35)
            case .available: return UIColor(red: 0.9, green: 0.9, blue: 0.6, alpha: 0.3)
            default: return .clear
            }

        }

        var zPosition: CGFloat {
            let normal = NodeType.square.zPosition
            switch self {
            case .normal: return normal
            case .origin: return normal + 20
            case .candidate: return normal + 15
            case .capture: return normal + 50
            case .target: return normal + 14
            case .defended: return normal + 30
            case .attacked: return normal + 40
            case .available: return normal + 10
            case .aggressive: return normal + 60
            }
        }

    }

}
