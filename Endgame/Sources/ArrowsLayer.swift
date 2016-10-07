//
//  ArrowsLayer.swift
//  Endgame
//
//  Created by Todd Olsen on 10/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

public typealias ArrowNode = SKShapeNode

enum ArrowType {
    case lastMove
    case attacking
    case guarding
    case user

    static let lastMoveName = "last-move-arrow"
    static let attackingName = "attacking-arrow"
    static let guardingName = "guarding-arrow"
    static let userName = "user-arrow"

    var name: String {
        switch self {
        case .lastMove: return ArrowType.lastMoveName
        case .attacking: return ArrowType.attackingName
        case .guarding: return ArrowType.guardingName
        case .user: return ArrowType.userName
        }
    }

    init(name: String) {
        switch name {
        case ArrowType.lastMoveName: self = .lastMove
        case ArrowType.attackingName: self = .attacking
        case ArrowType.guardingName: self = .guarding
        case ArrowType.userName: self = .user
        default: fatalError("Unexepected arrow name: \(name)")
        }
    }

}

public final class ArrowsLayer: SKSpriteNode, GameLayer {
    typealias NodeType = SKShapeNode

    var headLength: CGFloat {
        return squareSize.width/3
    }

    var headWidth: CGFloat {
        return squareSize.width/2
    }

    var tailWidth: CGFloat {
        return headWidth / 1.7
    }

    var originOffset: CGFloat {
        return squareSize.width/8
    }

    var targetOffset: CGFloat {
        return squareSize.width / 3.7
    }

//    func show(_ arrow: ArrowNode) {
//        let type = ArrowType(name: arrow.name!)
//    }

    func clearArrows(ofType type: ArrowType) {
        self[type.name].forEach { arrow in
            arrow.run(SKAction.fadeOut(withDuration: 0.2)) {
                arrow.removeFromParent()
            }
        }
    }

    func newArrow(for move: Move) -> ArrowNode {
        let path = UIBezierPath(
            origin: position(for: move.origin),
            target: position(for: move.target),
            tailWidth: tailWidth,
            headWidth: headWidth,
            headLength: headLength,
            originOffset: originOffset,
            targetOffset: targetOffset)
        return ArrowNode(path: path.cgPath)
    }

    func setLastMoveArrow(with move: Move?) {
        clearArrows(ofType: .lastMove)
        guard let move = move else { return }
        let arrowNode = newArrow(for: move)
        arrowNode.name = ArrowType.lastMove.name
        arrowNode.strokeColor = .init(white: 0.9, alpha: 0.9)
        arrowNode.fillColor = .init(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6)
        arrowNode.alpha = 0.0
        arrowNode.zPosition = 155
        addChild(arrowNode)
        arrowNode.run(SKAction.fadeIn(withDuration: 0.4))
    }

    var lastMoveArrow: ArrowNode? {
        return childNode(withName: "last move arrow") as! ArrowNode?
    }

    func path(for move: Move) -> UIBezierPath {

        let originPoint = position(for: move.origin)
        let targetPoint = position(for: move.target)

        return UIBezierPath(origin: originPoint, target: targetPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, originOffset: originOffset, targetOffset: targetOffset)
    }

}

extension UIBezierPath {

    convenience init(origin: CGPoint, target: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, originOffset: CGFloat = 0.0, targetOffset: CGFloat = 0.0) {

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
