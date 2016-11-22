//
//  BoardViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

public protocol BoardViewDelegate: class {
    func boardView(_ boardView: BoardViewType, didBeginActivityOn origin: Square)
    func boardView(_ boardView: BoardViewType, didMovePieceTo square: Square)
    func boardView(_ boardView: BoardViewType, didEndActivityWith move: Move, for pieceNode: Piece.Node)
    func boardViewDidNormalizeActivity(_ boardView: BoardViewType)
}
