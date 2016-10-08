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

    func highlightAvailable(squares: [Square]) {
        squares.map { squareNode(for: $0) }.forEach { $0.highlightType = .available }
    }

    func removeHighlights() {

    }

    public func squareNodes(for squares: [Square]) -> [SquareNode] {
        return squares.map(squareNode)
    }

    public func squareNode(for square: Square) -> SquareNode {
        guard let squareNode = childNode(withName: square.description) as? SquareNode else { fatalError() }
        return squareNode
    }

    func update(for activityState: ActivityState) {
        switch activityState {
        case .initiation(let origin):
            print("origin: \(origin)")
        case .normal:
            print("all is quiet")
        case .end(let move):
            print("execute \(move)")
        }
    }
}
