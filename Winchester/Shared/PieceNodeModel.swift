//
//  PieceNodeModel.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

protocol CaptureViewDelegate {
    func capture(_ piece: Piece) -> Void
    func resurrect(_ piece: Piece) -> Void
}

struct PieceNodeModel {

    /// Required
    private weak var scene: BoardScene!
    private let captureViewDelegate: CaptureViewDelegate

    init(scene: BoardScene, captureViewDelegate: CaptureViewDelegate) {
        self.scene = scene
        self.captureViewDelegate = captureViewDelegate
    }

    /// The default implementation returns the `PieceNode` in the scene at the given `Square` or `nil` if no pieceNode is there.
    func pieceNode(for square: Square, excepting exception: PieceNode? = nil) -> PieceNode? {
        return pieceNode(at: scene.position(for: square), excepting: exception)
    }

    /// The default implementation creates a new `PieceNode` with the given `Piece` and returns it.
    func pieceNode(for piece: Piece) -> PieceNode {
        let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
        let pieceNode = PieceNode(
            texture: SKTexture(imageNamed: imageName),
            color: .clear,
            size: scene.squareSize
        )
        pieceNode.name = String(piece.character)
        pieceNode.zPosition = NodeType.piece.zPosition

        return pieceNode
    }

    func pieceNode(at location: CGPoint, excepting exception: PieceNode? = nil) -> PieceNode? {
        let candidates = scene.children
            .filter { $0.contains(location) }
            .flatMap { $0 as? PieceNode }
            .filter { $0 != exception }
        guard let node = candidates.first else { return nil }
        return node
    }

    /// Takes a `PieceNode` and places it in the scene at `origin`'s location.
    func add(_ pieceNode: PieceNode, at origin: Square) {
        pieceNode.alpha = 0.0
        pieceNode.position = scene.position(for: origin)
        scene.addChild(pieceNode)
        pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
    }

    func resurrect(_ pieceNode: PieceNode, at origin: Square) {
        add(pieceNode, at: origin)
        captureViewDelegate.resurrect(pieceNode.piece())
    }

    /// Removes `pieceNode` from the scene.
    func remove(_ pieceNode: PieceNode) {
        pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
            pieceNode.removeFromParent()
        }
    }

    func capture(_ pieceNode: PieceNode) {
        remove(pieceNode)
        captureViewDelegate.capture(pieceNode.piece())
    }

    /// Animates the position of `pieceNode` to the location of `target`
    func move(_ pieceNode: PieceNode, to target: Square) {
        let action = SKAction.move(to: scene.position(for: target), duration: 0.2)
        action.timingMode = .easeInEaseOut
        pieceNode.run(action)
    }

    /// All the `PieceNode`s in the scene.
    func pieceNodes() -> [PieceNode] {
        return scene.children.flatMap { $0 as? PieceNode }
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
