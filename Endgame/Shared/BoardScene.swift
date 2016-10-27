//
//  BoardScene.swift
//  Winchester
//
//  Created by Todd Olsen on 10/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

protocol BoardInteractionDelegate {
    mutating func userDidTap(on square: Square)
    mutating func userDidPan(to square: Square?)
    mutating func userDidLongTap(on square: Square)
    mutating func userDidRelease(on square: Square?)
    mutating func userDidCancelSelection()
}

final class BoardScene: SKScene {

    // MARK: - Stored Properties

    var boardDelegate: BoardInteractionDelegate?

    // MARK: - Initializers

    override init() {
        super.init(size: CGSize.zero)
        isUserInteractionEnabled = true
        scaleMode = .aspectFill
        backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Functions and Properties

    func square(at location: CGPoint) -> Square? {
        guard contains(location) else { return nil }
        let rowWidth = size.width / 8.0
        // Determine which partition of the board (0..<8) the coordinate occupies.
        func partitionForCoordinate(_ coordinate: CGFloat) -> Int {
            var boundry = CGFloat.greatestFiniteMagnitude
            var partition = 8
            while (coordinate < boundry) && (partition > 0) {
                partition -= 1
                boundry = rowWidth * CGFloat(partition)
            }
            return partition
        }
        return Square(file: File(index: partitionForCoordinate(location.x)),
                      rank: Rank(index: partitionForCoordinate(location.y)))
    }

    func position(for square: Square) -> CGPoint {
        let x = start + offset(for: square.file.index)
        let y = start + offset(for: square.rank.index)
        return CGPoint(x: x, y: y)
    }

    var squareSize: CGSize {
        let rowCount: CGFloat = 8.0
        let edge = (size.width - (squareInset * (rowCount + 1.0))) / rowCount
        return CGSize(width: edge, height: edge)
    }

    var squareInset: CGFloat {
        return 1.0
    }

    var start: CGFloat {
        let boardEdge = size.width
        let squareEdge = squareSize.width
        let start = (-boardEdge + squareEdge) / 2.0
        return start + squareInset
    }

    func offset(for index: Int) -> CGFloat {
        return CGFloat(index) * (squareSize.width + squareInset)
    }

    private func nodes<A: SKSpriteNode>() -> [A] {
        return children.flatMap { $0 as? A }
    }

    private func node<A: SKSpriteNode>(at location: CGPoint) -> A? {
        let candidates = children
            .filter { $0.contains(location) }
            .flatMap { $0 as? A }
        guard let node = candidates.first else {
            return nil
        }
        return node
    }

    private var squareNodes: [SquareNode] {
        return nodes()
    }

    private var pieceNodes: [PieceNode] {
        return nodes()
    }

}
