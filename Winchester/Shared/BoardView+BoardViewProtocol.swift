//
//  BoardView+BoardViewProtocol.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

extension BoardView {

    // MARK: Square Nodes

    public var squareNodes: [Square.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Square.Node }
    }

    private func createSquareNode(with square: Square, ofKind kind: Square.Kind) -> Square.Node {
        let node = Square.Node(kind: kind, for: square)
        node.size = squareSize
        node.position = position(for: square)
        return node
    }

    private func addSquareNode(for square: Square, ofKind kind: Square.Kind) {
        let node = createSquareNode(with: square, ofKind: kind)
        _add(node)
    }

    public func present(_ squares: [Square], as kind: Square.Kind) {
        clearSquareNodes(ofKind: kind)
        for square in squares {
            addSquareNode(for: square, ofKind: kind)
        }
    }

    public func clearSquareNodes(ofKind kind: Square.Kind) {
        squareNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    public func clearSquareNodes() {
        Square.Kind.decorators.forEach(clearSquareNodes)
    }

    // MARK: Piece Nodes

    // All the `PieceNode`s in the scene.
    public var pieceNodes: [Piece.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Piece.Node }
    }

    /// Takes a `PieceNode` and places it in the scene at `origin`'s location.
    public func add(_ pieceNode: Piece.Node, at origin: Square) {
        pieceNode.position = position(for: origin)
        _add(pieceNode)
    }

    //    /// Removes `pieceNode` from the scene.
    public func remove(_ pieceNode: Piece.Node) {
        _remove(pieceNode)
    }

    /// Animates the position of `pieceNode` to the location of `target`
    public func move(_ pieceNode: Piece.Node, to target: Square) {
        pieceNode.run(_move(to: target))
    }

    public func updatePieces(with board: Board) {
        pieceNodes.forEach { $0.removeFromParent() }
        for space in board {
            if let piece = space.piece {
                add(pieceNode(for: piece), at: space.square)
            }
        }
    }

    // MARK: Arrow Nodes

    private var arrowNodes: [Arrow.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Arrow.Node }
    }

    private func createArrowNode(for move: Move, with kind: Arrow.Kind) -> Arrow.Node {
        let edge = squareSize.width
        let origin = position(for: move.origin)
        let target = position(for: move.target)
        return Arrow.Node(kind: kind, origin: origin, target: target, edge: edge)
    }

    public func presentArrows(for moves: [Move], ofKind kind: Arrow.Kind) {
        removeArrows(with: kind)
        for move in moves {
            addArrow(for: move, with: kind)
        }
    }

    func addArrow(for move: Move, with kind: Arrow.Kind) {
        let node = createArrowNode(for: move, with: kind)
        node.alpha = 0.0
        scene?.addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.2))
    }

    public func removeArrows(with kind: Arrow.Kind) {
        arrowNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    public func removeAllArrows() {
        Arrow.Kind.all.forEach(removeArrows)
    }

    private func _remove(_ node: SKNode) {
        node.run(SKAction.fadeOut(withDuration: 0.2)) {
            node.removeFromParent()
        }
    }

    private func _add(_ node: SKNode) {
        node.alpha = 0.0
        scene?.addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.2))
    }

    private func _move(to target: Square) -> SKAction {
        let action = SKAction.move(to: position(for: target), duration: 0.2)
        action.timingMode = .easeInEaseOut
        return action
    }
}
