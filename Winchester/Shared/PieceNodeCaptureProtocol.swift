//
//  PieceNodeCaptureProtocol.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

protocol PieceNodeCaptureProtocol {

    weak var capturingViewDelegate: CapturingViewDelegate? { get set }

    func resurrect(_ pieceNode: Piece.Node, at origin: Square)
    func capture(_ pieceNode: Piece.Node)

}

extension PieceNodeCaptureProtocol where Self: BoardViewProtocol, Self: PieceNodeDataSource {

    func resurrect(_ pieceNode: Piece.Node, at origin: Square) {
        add(pieceNode, at: origin)
        capturingViewDelegate?.resurrect(pieceNode.piece())
    }

    func capture(_ pieceNode: Piece.Node) {
        remove(pieceNode)
        capturingViewDelegate?.capture(pieceNode.piece())
    }
    
}
