//
//  PieceNodeDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import CoreGraphics
import Endgame

protocol PieceNodeDataSource {

    func pieceNode(for square: Square) -> Piece.Node?
    func pieceNode(for square: Square, excepting exception: Piece.Node?) -> Piece.Node?
    func pieceNode(at location: CGPoint) -> Piece.Node?
    func pieceNode(at location: CGPoint, excepting exception: Piece.Node?) -> Piece.Node?
    func pieceNode(for piece: Piece) -> Piece.Node

}

extension PieceNodeDataSource where Self: BoardViewProtocol {

    func pieceNode(for square: Square) -> Piece.Node? {
        return pieceNode(for: square, excepting: nil)
    }

    /// The default implementation returns the `PieceNode` in the scene at the given `Square` or `nil` if no pieceNode is there.
    func pieceNode(for square: Square, excepting exception: Piece.Node? = nil) -> Piece.Node? {
        return pieceNode(at: position(for: square), excepting: exception)
    }

    /// The default implementation creates a new `PieceNode` with the given `Piece` and returns it.
    func pieceNode(for piece: Piece) -> Piece.Node {

        return Piece.Node(piece: piece, size: squareSize)
    }

    func pieceNode(at location: CGPoint) -> Piece.Node? {
        return pieceNode(at: location, excepting: nil)
    }

    func pieceNode(at location: CGPoint, excepting exception: Piece.Node? = nil) -> Piece.Node? {
        let candidates = pieceNodes
            .filter { $0.contains(location) }
            .filter { $0 != exception }
        guard let node = candidates.first else { return nil }
        return node
    }
    
}
