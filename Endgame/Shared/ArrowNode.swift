//
//  ArrowNode.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

struct ArrowConfiguration {
    let name: String
    let stroke: UIColor
    let fill: UIColor
}

enum ArrowType {

    case lastMove
    case check
    case attacking
    case guarding
    case user

    static let _lastMove = ArrowConfiguration(name: "last-move-arrow", stroke: UIColor(white: 0.9, alpha: 0.9), fill: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6))

    static let lastMoveName = "last-move-arrow"
    static let checkName = "checking-arrow"
    static let attackingName = "attacking-arrow"
    static let guardingName = "guarding-arrow"
    static let userName = "user-arrow"

    var name: String {
        switch self {
        case .lastMove: return ArrowType._lastMove.name
        case .check: return ArrowType.checkName
        case .attacking: return ArrowType.attackingName
        case .guarding: return ArrowType.guardingName
        case .user: return ArrowType.userName
        }
    }

    var strokeColor: UIColor {
        switch self {
        case .lastMove: return ArrowType._lastMove.stroke
        case .check: return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.9)
        case .attacking: return UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 0.9)
        case .guarding: return UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 0.9)
        case .user: return UIColor(red: 0.5, green: 0.5, blue: 0.9, alpha: 0.9)
        }
    }

    var fillColor: UIColor {
        switch self {
        case .lastMove: return ArrowType._lastMove.fill
        case .check: return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.5)
        default:
            return UIColor.clear
        }
    }

    init(name: String) {
        switch name {
        case ArrowType.lastMoveName: self = .lastMove
        case ArrowType.checkName: self = .check
        case ArrowType.attackingName: self = .attacking
        case ArrowType.guardingName: self = .guarding
        case ArrowType.userName: self = .user
        default: fatalError("Unexepected arrow name: \(name)")
        }
    }

    func configure(_ arrowNode: ArrowNode) {
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

final class ArrowNode: SKShapeNode {

    var origin: Square
    var target: Square
    var type: ArrowType

    init(move: Move, type: ArrowType, path: CGPath) {
        self.origin = move.origin
        self.target = move.target
        self.type = type
        super.init()
        self.path = path
        self.zPosition = NodeType.arrow.zPosition
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
