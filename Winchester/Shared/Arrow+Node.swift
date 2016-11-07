//
//  Arrow+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

protocol ArrowNodeDataSource {

    func arrowNode(for move: Move, with kind: Arrow.Kind) -> Arrow.Node
    func setTarget(_ target: Square, for node: Arrow.Node)
    func removeArrows(with kind: Arrow.Kind)
    func add(_ arrowNode: Arrow.Node)
    func remove(_ arrowNode: Arrow.Node)

}

enum Arrow { }

extension Arrow {

    struct Configuration {
        let name: String
        let stroke: UIColor
        let fill: UIColor
    }

    enum Kind {

        case lastMove
        case check
        case attacking
        case guarding
        case user

        static let _lastMove = Configuration(name: "last-move-arrow", stroke: UIColor(white: 0.9, alpha: 0.9), fill: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6))

        static let lastMoveName = "last-move-arrow"
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

    struct DataSource: ArrowNodeDataSource {

        /// Required
        private weak var scene: BoardScene!

        init(scene: BoardScene) {
            self.scene = scene
        }

        /// Creates a new ArrowNode.
        func arrowNode(for move: Move, with kind: Arrow.Kind) -> Arrow.Node {

            let edge = scene.squareSize.width

            let path = UIBezierPath(
                origin: scene.position(for: move.origin),
                target: scene.position(for: move.target),
                tailWidth: kind.tailWidth(for: edge),
                headWidth: kind.headWidth(for: edge),
                headLength: kind.headLength(for: edge),
                originOffset: kind.originOffset(for: edge),
                targetOffset: kind.targetOffset(for: edge)
                ).cgPath

            let node = Arrow.Node(move: move, kind: kind, path: path)
            node.zPosition = NodeType.arrow.zPosition
            node.fillColor = kind.fillColor
            node.strokeColor = kind.strokeColor

            return node
        }

        func setTarget(_ target: Square, for node: Arrow.Node) {
            let origin = node.origin
            let oldTarget = node.target
            if oldTarget == target { return }

            let kind = node.kind
            let edge = scene.squareSize.width

            let newPath = UIBezierPath(
                origin: scene.position(for: origin),
                target: scene.position(for: target),
                tailWidth: kind.tailWidth(for: edge),
                headWidth: kind.headWidth(for: edge),
                headLength: kind.headLength(for: edge),
                originOffset: kind.originOffset(for: edge),
                targetOffset: kind.targetOffset(for: edge)
                ).cgPath
            node.path = newPath
        }

        func removeArrows(with kind: Arrow.Kind) {
            scene
                .children.flatMap { $0 as? Arrow.Node }
                .filter { $0.kind == kind }
                .forEach(remove)
        }

        func add(_ arrowNode: Arrow.Node) {
            arrowNode.alpha = 0.0
            scene.addChild(arrowNode)
            arrowNode.run(SKAction.fadeIn(withDuration: 0.2))
        }
        
        func remove(_ arrowNode: Arrow.Node) {
            arrowNode.run(SKAction.fadeOut(withDuration: 0.0)) {
                arrowNode.removeFromParent()
            }
        }

    }

}

extension UIBezierPath {

    convenience init(origin: CGPoint,
                     target: CGPoint,
                     tailWidth: CGFloat,
                     headWidth: CGFloat,
                     headLength: CGFloat,
                     originOffset: CGFloat = 0.0,
                     targetOffset: CGFloat = 0.0)
    {
        let length = CGFloat(hypot(
            (Double(target.x) - Double(origin.x)),
            (Double(target.y) - Double(origin.y))
        ))

        let points: [CGPoint] = {
            let tailLength = length - headLength - originOffset - targetOffset
            return [
                CGPoint(x: 0 + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: headWidth / 2),
                CGPoint(x: length - targetOffset, y: 0),
                CGPoint(x: tailLength + originOffset, y: -headWidth / 2),
                CGPoint(x: tailLength + originOffset, y: -tailWidth/2),
                CGPoint(x: 0 + originOffset, y: -tailWidth / 2)
            ]
        }()

        let transform: CGAffineTransform = {
            let cosine = (target.x - origin.x) / length
            let sine = (target.y - origin.y) / length
            return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: origin.x, ty: origin.y)
        }()

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        self.init(cgPath: path)
    }
    
}
