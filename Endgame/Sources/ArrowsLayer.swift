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

    func arrowNode(from origin: Square, to target: Square) -> SKShapeNode {
        return SKShapeNode(path: arrowPath(from: origin, to: target) as! CGPath)
    }

    func arrowPath(from origin: Square, to target: Square) -> UIBezierPath {

        let originPoint = position(for: origin)
        let targetPoint = position(for: target)

        let headLength = squareSize.width / 3
        let headWidth = squareSize.width / 2
        let tailWidth = headWidth / 1.7

        let originOffset = squareSize.width / 8
        let targetOffset = squareSize.width / 3.7

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
