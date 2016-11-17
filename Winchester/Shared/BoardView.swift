//
//  BoardView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

final class BoardView: SKView, BoardViewType {

    // BoardViewType
    weak var capturingViewDelegate: CapturingViewDelegate?

    // BoardInteractionProtocol
    var interactionState: BoardView.InteractionState = .dormant
    var initialSquare: Square?
    weak var activeNode: Piece.Node?

    public fileprivate(set) var currentOrientation: BoardView.Orientation = .bottom

}

extension BoardView {

    enum InteractionState {
        case dormant
        case active(Square)
        case ended(Move)
    }

    enum Orientation {

        case bottom
        case right
        case top
        case left

        init(angle: CGFloat) {

            var ref = angle
            while ref > 2.0 * .pi {
                ref -= 2.0 * .pi
            }

            if (0.75 * .pi) > ref && ref >= (0.25 * .pi) {
                self = .right
            } else if (1.25 * .pi) > ref && ref >= (0.75 * .pi) {
                self = .top
            } else if (1.75 * .pi) > ref && ref >= (1.25 * .pi) {
                self = .left
            } else {
                self = .bottom
            }
        }

        static var all: [Orientation] {
            return [.bottom, .right, .top, .left]
        }

        func angle() -> CGFloat {
            let multiplier: CGFloat
            switch self {
            case .bottom: multiplier = 0.0
            case .right: multiplier = 0.5
            case .top: multiplier = 1.0
            case .left: multiplier = 1.5
            }
            return .pi * -multiplier
        }

        mutating func rotate() {
            switch self {
            case .bottom: self = .right
            case .right: self = .top
            case .top: self = .left
            case .left: self = .bottom
            }
        }
        
    }

}

extension BoardView {

    func rotateView() {
        currentOrientation.rotate()
        SKView.animate(withDuration: 0.3) {
            self.transform = self.transform.rotated(by: .pi * -0.5)
        }
    }

}

extension BoardView: BoardViewProtocol {

    func setup(with board: Board) {
//        guard let scene = scene else { fatalError("Error: cannot setup board without a scene.") }
//        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        scene.scaleMode = .resizeFill
//        present(Square.all, as: .normal)
        updatePieces(with: board)
    }

    // MARK: Square Nodes

    var squareNodes: [Square.Node] {
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

    func present(_ squares: [Square], as kind: Square.Kind) {
        clearSquareNodes(ofKind: kind)
        for square in squares {
            addSquareNode(for: square, ofKind: kind)
        }
    }

    func clearSquareNodes(ofKind kind: Square.Kind) {
        squareNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    func clearSquareNodes() {
        Square.Kind.decorators.forEach(clearSquareNodes)
    }

    // MARK: Piece Nodes 

    // All the `PieceNode`s in the scene.
    var pieceNodes: [Piece.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Piece.Node }
    }

    /// Takes a `PieceNode` and places it in the scene at `origin`'s location.
    func add(_ pieceNode: Piece.Node, at origin: Square) {
        pieceNode.position = position(for: origin)
        _add(pieceNode)
    }

//    /// Removes `pieceNode` from the scene.
    func remove(_ pieceNode: Piece.Node) {
        _remove(pieceNode)
    }

    /// Animates the position of `pieceNode` to the location of `target`
    func move(_ pieceNode: Piece.Node, to target: Square) {
        pieceNode.run(_move(to: target))
    }

    func updatePieces(with board: Board) {
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

    /// Creates a new ArrowNode.
    private func createArrowNode(for move: Move, with kind: Arrow.Kind) -> Arrow.Node {

        let edge = squareSize.width

        let path = CGPath.arrow(
            origin: position(for: move.origin),
            target: position(for: move.target),
            tailWidth: kind.tailWidth(for: edge),
            headWidth: kind.headWidth(for: edge),
            headLength: kind.headLength(for: edge),
            originOffset: kind.originOffset(for: edge),
            targetOffset: kind.targetOffset(for: edge)
            )

        let node = Arrow.Node(move: move, kind: kind, path: path)
        node.zPosition = NodeType.arrow.zPosition
        node.fillColor = kind.fillColor
        node.strokeColor = kind.strokeColor

        return node
    }

    func presentArrows(for moves: [Move], ofKind kind: Arrow.Kind) {
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

    func removeArrows(with kind: Arrow.Kind) {
        arrowNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    func removeAllArrows() {
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

//extension BoardViewType where Self: GameDelegate {
//
//    func game(_ game: Game, didAppend item: HistoryItem, at index: Int?) {
////        updateHistoryItem(index)
//    }
//
//    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
//
//    }
//
//    func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction) {
//        traverse(items, in: direction)
//    }
//
//}
