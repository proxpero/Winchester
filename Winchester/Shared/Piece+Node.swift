//
//  Piece+Node.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

protocol CaptureViewDelegate {
    func capture(_ piece: Piece) -> Void
    func resurrect(_ piece: Piece) -> Void
}

protocol PieceNodeDataSource {

    func pieceNode(for square: Square) -> Piece.Node?
    func pieceNode(for square: Square, excepting exception: Piece.Node?) -> Piece.Node?
    func pieceNode(at location: CGPoint) -> Piece.Node?
    func pieceNode(at location: CGPoint, excepting exception: Piece.Node?) -> Piece.Node?
    func pieceNode(for piece: Piece) -> Piece.Node

    func add(_ pieceNode: Piece.Node, at origin: Square)
    func resurrect(_ pieceNode: Piece.Node, at origin: Square)
    func remove(_ pieceNode: Piece.Node)
    func capture(_ pieceNode: Piece.Node)
    func move(_ pieceNode: Piece.Node, to target: Square)
    func pieceNodes() -> [Piece.Node]
    
}


extension Piece {

    final class Node: SKSpriteNode {

        init(piece: Piece, size: CGSize) {
            let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
            super.init(
                texture: SKTexture(imageNamed: imageName),
                color: .clear,
                size: size)
            name = String(piece.character)
            zPosition = NodeType.piece.zPosition
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func piece() -> Piece {
            guard
                let name = name,
                let char = name.characters.first,
                let piece = Piece(character: char)
                else { fatalError() }
            return piece
        }

    }

    struct DataSource: PieceNodeDataSource {

        /// Required
        private weak var scene: BoardScene!
        private let captureViewDelegate: CaptureViewDelegate

        init(scene: BoardScene, captureViewDelegate: CaptureViewDelegate) {
            self.scene = scene
            self.captureViewDelegate = captureViewDelegate
        }

        func pieceNode(for square: Square) -> Node? {
            return pieceNode(for: square, excepting: nil)
        }

        /// The default implementation returns the `PieceNode` in the scene at the given `Square` or `nil` if no pieceNode is there.
        func pieceNode(for square: Square, excepting exception: Node? = nil) -> Node? {
            return pieceNode(at: scene.position(for: square), excepting: exception)
        }

        /// The default implementation creates a new `PieceNode` with the given `Piece` and returns it.
        func pieceNode(for piece: Piece) -> Node {

            return Node(piece: piece, size: scene.squareSize)
        }

        func pieceNode(at location: CGPoint) -> Node? {
            return pieceNode(at: location, excepting: nil)
        }

        func pieceNode(at location: CGPoint, excepting exception: Node? = nil) -> Node? {
            let candidates = scene.children
                .filter { $0.contains(location) }
                .flatMap { $0 as? Node }
                .filter { $0 != exception }
            guard let node = candidates.first else { return nil }
            return node
        }

        /// Takes a `PieceNode` and places it in the scene at `origin`'s location.
        func add(_ pieceNode: Node, at origin: Square) {
            pieceNode.alpha = 0.0
            pieceNode.position = scene.position(for: origin)
            scene.addChild(pieceNode)
            pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
        }

        func resurrect(_ pieceNode: Node, at origin: Square) {
            add(pieceNode, at: origin)
            captureViewDelegate.resurrect(pieceNode.piece())
        }

        /// Removes `pieceNode` from the scene.
        func remove(_ pieceNode: Node) {
            pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                pieceNode.removeFromParent()
            }
        }

        func capture(_ pieceNode: Node) {
            remove(pieceNode)
            captureViewDelegate.capture(pieceNode.piece())
        }

        /// Animates the position of `pieceNode` to the location of `target`
        func move(_ pieceNode: Node, to target: Square) {
            let action = SKAction.move(to: scene.position(for: target), duration: 0.2)
            action.timingMode = .easeInEaseOut
            pieceNode.run(action)
        }

        /// All the `PieceNode`s in the scene.
        func pieceNodes() -> [Node] {
            return scene.children.flatMap { $0 as? Node }
        }
        
        func updatePieces(with board: Board) {
            pieceNodes().forEach { $0.removeFromParent() }
            for space in board {
                if let piece = space.piece {
                    add(pieceNode(for: piece), at: space.square)
                }
            }
        }
        

    }


}

final class PieceNode: SKSpriteNode {
    func piece() -> Piece {
        guard
            let name = name,
            let char = name.characters.first,
            let piece = Piece(character: char)
            else { fatalError() }
        return piece
    }
}

