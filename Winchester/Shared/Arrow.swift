//
//  Arrow+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

public enum Arrow { }

extension Arrow {

    struct Configuration {
        let name: String
        let stroke: UIColor
        let fill: UIColor
    }

    public enum Kind {

        case lastMove
        case check
        case attacking
        case guarding
        case user

        static let _lastMove = Configuration(name: "last-move-arrow", stroke: UIColor(white: 0.9, alpha: 0.9), fill: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6))

        static let all: [Kind] = [.lastMove, .check, .attacking, .guarding, .user]

        static let lastMoveName = Kind._lastMove.name
        static let checkName = "checking-arrow"
        static let attackingName = "attacking-arrow"
        static let guardingName = "guarding-arrow"
        static let userName = "user-arrow"

        var name: String {
            switch self {
            case .lastMove: return Kind._lastMove.name
            case .check: return Kind.checkName
            case .attacking: return Kind.attackingName
            case .guarding: return Kind.guardingName
            case .user: return Kind.userName
            }
        }

        var strokeColor: UIColor {
            switch self {
            case .lastMove: return Kind._lastMove.stroke
            case .check: return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.9)
            case .attacking: return UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 0.9)
            case .guarding: return UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 0.9)
            case .user: return UIColor(red: 0.5, green: 0.5, blue: 0.9, alpha: 0.9)
            }
        }

        var fillColor: UIColor {
            switch self {
            case .lastMove: return Kind._lastMove.fill
            case .check: return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.5)
            default:
                return UIColor.clear
            }
        }

        init(name: String) {
            switch name {
            case Kind.lastMoveName: self = .lastMove
            case Kind.checkName: self = .check
            case Kind.attackingName: self = .attacking
            case Kind.guardingName: self = .guarding
            case Kind.userName: self = .user
            default: fatalError("Unexepected arrow name: \(name)")
            }
        }

        func configure(_ arrowNode: Node) {
            arrowNode.name = name
            arrowNode.strokeColor = strokeColor
            arrowNode.fillColor = fillColor
        }

        func headLength(for edge: CGFloat) -> CGFloat {
            let multiplier: CGFloat = {
                switch self {
                default: return 0.333
                }
            }()
            return edge * multiplier
        }

        func headWidth(for edge: CGFloat) -> CGFloat {
            let multiplier: CGFloat = {
                switch self {
                default: return 0.500
                }
            }()
            return edge * multiplier
        }

        func tailWidth(for edge: CGFloat) -> CGFloat {
            let multiplier: CGFloat = {
                switch self {
                default: return 0.294
                }
            }()
            return edge * multiplier
        }

        func originOffset(for edge: CGFloat) -> CGFloat {
            let multiplier: CGFloat = {
                switch self {
                default: return 0.125
                }
            }()
            return edge * multiplier
        }

        func targetOffset(for edge: CGFloat) -> CGFloat {
            let multiplier: CGFloat = {
                switch self {
                default: return 0.270
                }
            }()
            return edge * multiplier
        }

    }

    final class Node: SKShapeNode {
        
        var origin: Square
        var target: Square
        var kind: Kind

        init(kind: Kind, origin: CGPoint, target: CGPoint, edge: CGFloat) {
            self.origin = .a1
            self.target = .a8
            self.kind = kind

            super.init()

            let path = CGPath.arrow(
                origin: origin,
                target: target,
                tailWidth: kind.tailWidth(for: edge),
                headWidth: kind.headWidth(for: edge),
                headLength: kind.headLength(for: edge),
                originOffset: kind.originOffset(for: edge),
                targetOffset: kind.targetOffset(for: edge)
            )
            self.path = path
            self.zPosition = NodeType.arrow.zPosition
            self.name = kind.name

            self.fillColor = kind.fillColor
            self.strokeColor = kind.strokeColor
            
        }

        init(move: Move, kind: Kind, path: CGPath) {
            self.origin = move.origin
            self.target = move.target
            self.kind = kind
            super.init()
            self.path = path
            self.zPosition = NodeType.arrow.zPosition
            self.name = kind.name
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
}
