//
//  SquaresLayer.swift
//  Endgame
//
//  Created by Todd Olsen on 10/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

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
