//
//  GameLayer.swift
//  Endgame
//
//  Created by Todd Olsen on 8/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

protocol GameLayer {

    associatedtype NodeType

    var nodes: [NodeType] { get }
    var squareInset: CGFloat { get }
    var squareSize: CGSize { get }
    var start: CGFloat { get }
    init(size: CGSize)
    func position(for square: Square) -> CGPoint

}

extension GameLayer where Self: SKSpriteNode, NodeType: SKSpriteNode {

    internal init(size: CGSize) {
        self = Self.init(texture: nil, color: .clear, size: size)
    }

    var count: CGFloat {
        return 8.0
    }

    var squareInset: CGFloat {
        return 1.0
    }

    var squareSize: CGSize {
        let edge = (size.width - (squareInset * (count + 1.0))) / count
        return CGSize(width: edge, height: edge)
    }

    var start: CGFloat {
        let boardEdge = size.width
        let squareEdge = squareSize.width
        let start = (-boardEdge + squareEdge) / 2.0
        return start + squareInset
    }

    private func offset(for index: Int) -> CGFloat {
        return CGFloat(index) * (squareSize.width + squareInset)
    }

    func position(for square: Square) -> CGPoint {
        let x = start + offset(for: square.file.index)
        let y = start + offset(for: square.rank.index)
        return CGPoint(x: x, y: y)
    }

    var nodes: [NodeType] {
        guard let nodes = children as? [NodeType] else { fatalError() }
        return nodes
    }

    func node(at location: CGPoint) -> NodeType? {
        return nodes.filter({ $0.contains(location) }).first
    }

    func node(for square: Square) -> NodeType? {
        return node(at: self.position(for: square))
    }

}

public final class SquaresLayer: SKSpriteNode, GameLayer {

    typealias NodeType = SquareNode

    public func setupSquares() {

        for square in Square.all {
            let squareNode = SquareNode(square: square, with: squareSize)
            squareNode.position = position(for: square)
            squareNode.zPosition = 10
            squareNode.name = square.description
            addChild(squareNode)
        }

    }

    func removeHighlights() {
        nodes
            .filter { $0.highlightType != .none }
            .forEach { $0.highlightType = .none }
    }

    public func squareNodes(for squares: [Square]) -> [SquareNode] {
        return squares.map(squareNode)
    }

    public func squareNode(for square: Square) -> SquareNode {
        guard let squareNode = childNode(withName: square.description) as? SquareNode else { fatalError() }
        return squareNode
    }
}

public final class PiecesLayer: SKSpriteNode, GameLayer {

    typealias NodeType = PieceNode

    public func createPieceNode(from piece: Piece, location: Square) -> PieceNode {
        let pieceNode = PieceNode(piece: piece, with: squareSize)
        pieceNode.position = position(for: location)
        pieceNode.name = piece.description
        return pieceNode
    }

    public func setupPieces(for board: Board) {

        for space in board {
            if let piece = space.piece {
                let pieceNode = createPieceNode(from: piece, location: Square(file: space.file, rank: space.rank))
                addChild(pieceNode)
            }
        }
        
    }

    public func movePiece(from origin: Square, to target: Square, animated: Bool) {
        guard let pieceNode = node(for: origin) else { return }
        place(pieceNode: pieceNode, on: target)
    }

    public func place(pieceNode: PieceNode, on target: Square) {

        let capture = node(for: target)
        let action = SKAction.move(to: position(for: target), duration: 0.2)
        action.timingMode = .easeInEaseOut
        pieceNode.zPosition += 20
        pieceNode.run(action) {
            print("Here I am: \(pieceNode.position)")
            capture?.removeFromParent()
            pieceNode.zPosition -= 20
        }
    }



}
