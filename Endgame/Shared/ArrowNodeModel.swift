//
//  ArrowNodeModel.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

struct ArrowNodeModel {
    /// Required
    private let scene: BoardScene

    init(scene: BoardScene) {
        self.scene = scene
    }

    /// Creates a new ArrowNode.
    func arrowNode(for move: Move, with type: ArrowType) -> ArrowNode {

        let edge = scene.squareSize.width

        let path = UIBezierPath(
            origin: scene.position(for: move.origin),
            target: scene.position(for: move.target),
            tailWidth: type.tailWidth(for: edge),
            headWidth: type.headWidth(for: edge),
            headLength: type.headLength(for: edge),
            originOffset: type.originOffset(for: edge),
            targetOffset: type.targetOffset(for: edge)
        ).cgPath

        let node = ArrowNode(move: move, type: type, path: path)
        node.name = type.name
        node.zPosition = NodeType.arrow.zPosition
        node.fillColor = type.fillColor
        node.strokeColor = type.strokeColor

        node.userData = NSMutableDictionary()
        node.userData!["origin"] = move.origin.description
        node.userData!["target"] = move.target.description
        node.userData!["type"] = type.name

        return node
        
    }

    func setTarget(_ target: Square, for node: ArrowNode) {
        let origin = node.origin
        let oldTarget = node.target
        if oldTarget == target { return }

        let type = node.type
        let edge = scene.squareSize.width

        let newPath = UIBezierPath(
            origin: scene.position(for: origin),
            target: scene.position(for: target),
            tailWidth: type.tailWidth(for: edge),
            headWidth: type.headWidth(for: edge),
            headLength: type.headLength(for: edge),
            originOffset: type.originOffset(for: edge),
            targetOffset: type.targetOffset(for: edge)
        ).cgPath
        node.path = newPath
    }

    func removeArrows(with type: ArrowType) {
        scene
            .children.flatMap { $0 as? ArrowNode }
            .filter { $0.type == type }
            .forEach { arrowNode in
                arrowNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                    arrowNode.removeFromParent()
                }
        }
    }

    func add(_ arrowNode: ArrowNode) {
        arrowNode.alpha = 0.0
        scene.addChild(arrowNode)
        arrowNode.run(SKAction.fadeIn(withDuration: 0.2))
    }

    func remove(_ arrowNode: ArrowNode) {
        arrowNode.run(SKAction.fadeOut(withDuration: 0.2)) {
            arrowNode.removeFromParent()
        }
    }
}
