//
//  Square+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

protocol SquareNodeDataSource {

    func squareNodes() -> [Square.Node]
    func squareNode(with square: Square, ofKind kind: Square.Kind) -> Square.Node
    func presentSquareNodes(for squares: [Square], ofKind kind: Square.Kind)
    func add(_ squareNode: Square.Node)
    func clearSquareNodes(ofKind kind: Square.Kind)
    func placeSquares()
    
}

extension Square {

    final class Node: SKSpriteNode {

        let kind: Kind

        init(kind: Kind, for square: Square) {
            self.kind = kind
            super.init(texture: kind.texture(for: square), color: kind.color(for: square), size: CGSize.zero)
            self.zPosition = kind.zPosition
            self.name = square.description
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

    enum Kind {

        case normal
        case origin
        case candidate
        case target
        case capture
        case defended
        case attacked
        case available
        case aggressive

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

    struct DataSource: SquareNodeDataSource {

        private weak var scene: BoardScene!

        init(scene: BoardScene) {
            self.scene = scene
        }

        func placeSquares() {
            squareNodes().forEach { $0.removeFromParent() }
            for square in Square.all {
                scene.addChild(squareNode(with: square, ofKind: .normal))
            }
        }

        func squareNodes() -> [Node] {
            return scene.children.flatMap { $0 as? Node }
        }

        func squareNode(with square: Square, ofKind kind: Kind) -> Node {
            let node = Node(kind: kind, for: square)
            node.size = scene.squareSize
            node.position = scene.position(for: square)
            return node
        }

        func presentSquareNodes(for squares: [Square], ofKind kind: Kind) {
            clearSquareNodes(ofKind: kind)
            for square in squares {
                let node = squareNode(with: square, ofKind: kind)
                add(node)
            }
        }

        func add(_ squareNode: Node) {
            squareNode.alpha = 0.0
            scene.addChild(squareNode)
            squareNode.run(SKAction.fadeIn(withDuration: 0.2))
        }

        func clearSquareNodes(ofKind kind: Kind) {
            squareNodes()
                .filter { $0.kind == kind }
                .forEach { squareNode in
                    squareNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                        squareNode.removeFromParent()
                    }
            }
        }

    }

}
