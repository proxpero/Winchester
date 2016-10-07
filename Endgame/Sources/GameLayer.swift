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


