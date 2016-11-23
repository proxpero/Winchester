//
//  PieceCapturingViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

/// The delegate of a view that shows captures pieces.
public protocol PieceCapturingViewDelegate: class {
    func capture(_ piece: Piece) -> Void
    func resurrect(_ piece: Piece) -> Void
}
