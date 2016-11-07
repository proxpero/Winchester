//
//  CaptureViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/31/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Endgame

public final class CaptureViewController: UIViewController, CaptureViewDelegate {

    var scene: SKScene!
    var pieceSize: CGSize!

    public override func viewDidLoad() {
        super.viewDidLoad()
        scene = SKScene()
        scene.backgroundColor = UIColor.clear
        scene.scaleMode = .aspectFill
        scene.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }

    private var _isPresented = false

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scene.size = view.bounds.size
        pieceSize = CGSize(edge: (scene.size.area()/16.0).squareRoot())

        if scene.view == nil {
            guard let skview = view as? SKView else { fatalError() }
            skview.presentScene(scene)
            scene.addChild(boundaryNode())
        }

    }

    func capture(_ piece: Piece) -> Void {
        let pieceNode = capturedPieceNode(for: piece)
        scene.addChild(pieceNode)
        let direction: CGFloat = piece.color.isWhite ? -1 : 1
        pieceNode.run(SKAction.applyForce(CGVector(dx: direction*800, dy: 0), duration: 0.3))
        pieceNode.run(SKAction.fadeIn(withDuration: 0.3))
    }

    func resurrect(_ piece: Piece) -> Void {
        let pieceName = String(piece.character)
        let candidates = scene.children.filter { $0.name == pieceName }
        if !candidates.isEmpty {
            let node = candidates.first
            node?.run(SKAction.applyForce(CGVector(dx: 0, dy: 10000), duration: 0.3))
            node?.run(SKAction.fadeOut(withDuration: 0.3)) {
                node?.removeFromParent()
            }
        }
    }

    func capturedPieceNode(for piece: Piece) -> Piece.Node {
        let pieceNode = Piece.Node(piece: piece, size: pieceSize)
        let side: CGFloat = piece.color.isWhite ? 0.5 : 1.5
        let center = CGPoint(x: (scene.size.width/2) * side, y: scene.size.height/2)
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

    func boundaryNode() -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: view.bounds.size))
        node.strokeColor = UIColor.clear
        node.fillColor = UIColor.clear
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: view.bounds.size))
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
