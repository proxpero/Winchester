//
//  Position+View.swift
//  Engine
//
//  Created by Todd Olsen on 9/24/16.
//
//

import Foundation
import CoreGraphics

extension Position {
    public func thumbnail(edge: CGFloat) -> ChessView {
        return board.view(edge: edge)
    }
}
