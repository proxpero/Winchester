//
//  Capture.swift
//  Engine
//
//  Created by Todd Olsen on 9/28/16.
//
//

public struct Capture {
    let piece: Piece
    let square: Square
}

extension Capture: Equatable {
    public static func == (lhs: Capture, rhs: Capture) -> Bool {
        return lhs.piece == rhs.piece && lhs.square == rhs.square
    }
}
