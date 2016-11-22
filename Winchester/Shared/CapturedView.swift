//
//  CapturedView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

/// The delegate of a view that shows captures pieces.
public protocol CapturingViewDelegate: class {
    func capture(_ piece: Piece) -> Void
    func resurrect(_ piece: Piece) -> Void
}

public final class CapturedView: SKView, CapturingViewDelegate {

    var pieceSize: CGSize!

    func setup() {
        guard let scene = scene else {
            return
        }
        scene.addChild(boundaryNode)
    }

    public func capture(_ piece: Piece) -> Void {
        let pieceNode = capturedPieceNode(for: piece)
        scene?.addChild(pieceNode)
        let direction: CGFloat = piece.color.isWhite ? -1 : 1
        pieceNode.run(SKAction.applyForce(CGVector(dx: direction*800, dy: 0), duration: 0.3))
        pieceNode.run(SKAction.fadeIn(withDuration: 0.3))
    }

    public func resurrect(_ piece: Piece) -> Void {
        let candidates = scene!.children
            .flatMap { $0 as? Piece.Node }
            .filter { $0.name != nil && $0.piece() == piece }
        if !candidates.isEmpty {
            let node = candidates.first
            node?.name = nil // This is to make sure the node isn't already on its way out.
            node?.run(SKAction.applyForce(CGVector(dx: 0, dy: 10000), duration: 0.3))
            node?.run(SKAction.fadeOut(withDuration: 0.3)) {
                node?.removeFromParent()
            }
        }
    }

    private func capturedPieceNode(for piece: Piece) -> Piece.Node {
        let pieceNode = Piece.Node(piece: piece, size: pieceSize)
        let side: CGFloat = piece.color.isWhite ? 0.5 : 1.5
        let center = CGPoint(x: (scene!.size.width/2) * side, y: scene!.size.height/2)
        pieceNode.position = center
        pieceNode.name = String(piece.character)
        pieceNode.zPosition = NodeType.piece.zPosition
        pieceNode.physicsBody = SKPhysicsBody(circleOfRadius: pieceSize.width/4)
        pieceNode.physicsBody?.affectedByGravity = true
        pieceNode.physicsBody?.usesPreciseCollisionDetection = true
        pieceNode.physicsBody?.collisionBitMask = 1
        pieceNode.physicsBody?.mass = 3.0
        pieceNode.physicsBody?.restitution = 0.6
        pieceNode.alpha = 0.0

        return pieceNode
    }

    private var boundaryNode: SKShapeNode {
        let node = SKShapeNode(rect: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: bounds.size))
        node.strokeColor = UIColor.clear
        node.fillColor = UIColor.clear
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: bounds.size))
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        node.physicsBody?.collisionBitMask = 1
        node.position = CGPoint(x: 0, y: 0)
        node.zPosition = 10
        return node
    }
}

extension CGSize {
    func area() -> CGFloat {
        return width * height
    }
    init(edge: CGFloat) {
        self = CGSize(width: edge, height: edge)
    }
}
