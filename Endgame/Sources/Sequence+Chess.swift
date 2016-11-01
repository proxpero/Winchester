//
//  Sequence+Chess.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

extension Sequence where Iterator.Element == Square {

    /// Creates an array of moves each having `origin` and the origin square
    /// and the squares in `self` are mapped to the move's target square.
    public func moves(from origin: Square) -> [Move] {
        return self.map { Move(origin: origin, target: $0) }
    }

    /// Returns moves from the squares in `self` to `square`.
    public func moves(to target: Square) -> [Move] {
        return self.map { Move(origin: $0, target: target) }
    }
    
}
