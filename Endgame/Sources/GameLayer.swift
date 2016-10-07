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

extension GameLayer where Self: SKSpriteNode, NodeType: SKNode {

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
            squareNode.zPosition = 110
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

public typealias ArrowNode = SKShapeNode

public final class ArrowsLayer: SKSpriteNode, GameLayer {
    typealias NodeType = SKShapeNode

    var headLength: CGFloat {
        return squareSize.width/3
    }

    var headWidth: CGFloat {
        return squareSize.width/2
    }

    var tailWidth: CGFloat {
        return headWidth / 1.7
    }

    var originOffset: CGFloat {
        return squareSize.width/8
    }

    var targetOffset: CGFloat {
        return squareSize.width / 3.7
    }

    func newArrow(for move: Move) -> ArrowNode {
        let path = UIBezierPath(
            origin: position(for: move.origin),
            target: position(for: move.target),
            tailWidth: tailWidth,
            headWidth: headWidth,
            headLength: headLength,
            originOffset: originOffset,
            targetOffset: targetOffset)
        return ArrowNode(path: path.cgPath)
    }

    func arrowNode(from origin: Square, to target: Square) -> SKShapeNode {
        return SKShapeNode(path: arrowPath(from: origin, to: target) as! CGPath)
    }

    func arrowPath(from origin: Square, to target: Square) -> UIBezierPath {

        let originPoint = position(for: origin)
        let targetPoint = position(for: target)

        let headLength = squareSize.width / 3
        let headWidth = squareSize.width / 2
        let tailWidth = headWidth / 1.7

        let originOffset = squareSize.width / 8
        let targetOffset = squareSize.width / 3.7

        return UIBezierPath(origin: originPoint, target: targetPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, originOffset: originOffset, targetOffset: targetOffset)
    }

}

extension UIBezierPath {

    convenience init(origin: CGPoint, target: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, originOffset: CGFloat = 0.0, targetOffset: CGFloat = 0.0) {

        let length = CGFloat(hypot(
            (Double(target.x) - Double(origin.x)),
            (Double(target.y) - Double(origin.y))
        ))

        let points: [CGPoint] = {
            let tailLength = length - headLength - originOffset - targetOffset
            return [
                CGPoint(x: 0 + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: headWidth / 2),
                CGPoint(x: length - targetOffset, y: 0),
                CGPoint(x: tailLength + originOffset, y: -headWidth / 2),
                CGPoint(x: tailLength + originOffset, y: -tailWidth/2),
                CGPoint(x: 0 + originOffset, y: -tailWidth / 2)
            ]
        }()

        let transform: CGAffineTransform = {
            let cosine = (target.x - origin.x) / length
            let sine = (target.y - origin.y) / length
            return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: origin.x, ty: origin.y)
        }()

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        self.init(cgPath: path)
    }
    
}

public typealias PieceNode = SKSpriteNode

public final class PiecesLayer: SKSpriteNode, GameLayer {

    typealias NodeType = PieceNode

    public func pieceNode(for piece: Piece) -> PieceNode {

        let imageName = "\(piece.color == .white ? "White" : "Black")\(piece.kind.name)"
        let pieceNode = PieceNode(
            texture: SKTexture(imageNamed: imageName),
            color: .clear,
            size: squareSize
        )

        pieceNode.name = String(piece.character)
        pieceNode.zPosition = 210

        return pieceNode
    }

    public func setupPieces(for board: Board) {
        for space in board {
            if let piece = space.piece {
                let node = self.pieceNode(for: piece)
                node.position = position(for: space.square)
                addChild(node)
            }
        }
    }

    func perform(_ transaction: Transaction, on pieceNode: PieceNode) {
        if transaction.status == .removed {
            pieceNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                pieceNode.removeFromParent()
            }
        } else {
            if transaction.status == .added {
                pieceNode.alpha = 0.0
                pieceNode.position = position(for: transaction.origin)
                addChild(pieceNode)
                pieceNode.run(SKAction.fadeIn(withDuration: 0.2))
            }
            pieceNode.run(SKAction.move(to: position(for: transaction.target), duration: 0.2))
        }
    }
}
