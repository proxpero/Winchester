//
//  SquareNodeModel.swift
//  Endgame
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

struct SquareNodeModel {

    private let scene: BoardScene

    init(scene: BoardScene) {
        self.scene = scene
    }

    func square(at location: CGPoint) -> Square? {
        return scene.square(at: location)
    }

    func placeSquares() {
        squareNodes().forEach { $0.removeFromParent() }
        for square in Square.all {
            scene.addChild(squareNode(with: square, ofType: .normal(square)))
        }
    }

    func squareNodes() -> [SquareNode] {
        return scene.children.flatMap { $0 as? SquareNode }
    }

    func squareNode(with square: Square, ofType type: SquareType) -> SquareNode {

        let node = SquareNode(type: type)
        node.size = scene.squareSize
        node.position = scene.position(for: square)
        node.zPosition = NodeType.square.zPosition
        node.name = square.description
        return node
    }

    func presentSquareNodes(for squares: [Square], ofType type: SquareType) {
        
    }

    func add(_ squareNode: SquareNode) {
        squareNode.alpha = 0.0
        scene.addChild(squareNode)
        squareNode.run(SKAction.fadeIn(withDuration: 0.2))
    }

    func clearSquareNodes(ofType type: SquareType) {

        squareNodes()
            .filter { $0.type == type }
            .forEach { squareNode in
                squareNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                    squareNode.removeFromParent()
                }
        }
    }

}
