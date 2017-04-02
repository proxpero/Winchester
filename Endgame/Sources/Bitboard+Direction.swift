//
//  Bitboard+Direction.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Bitboard {

    /// A bitboard shift direction.
    public enum Direction {
        case north
        case south
        case east
        case west
        case northeast
        case southeast
        case northwest
        case southwest
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    public func shifted(toward direction: Direction) -> Bitboard {
        switch direction {
        case .north:     return  self << 8
        case .south:     return  self >> 8
        case .east:      return (self << 1) & ~File.a
        case .northeast: return (self << 9) & ~File.a
        case .southeast: return (self >> 7) & ~File.a
        case .west:      return (self >> 1) & ~File.h
        case .southwest: return (self >> 9) & ~File.h
        case .northwest: return (self << 7) & ~File.h
        }
    }

    /// Returns the bits of `self` filled toward `direction` until stopped by `obstacles`.
    public func filled(toward direction: Direction, until obstacles: Bitboard) -> Bitboard {
        let empty = ~obstacles
        var bitboard = self
        for _ in 0 ..< 7 {
            bitboard |= empty & bitboard.shifted(toward: direction)
        }
        return bitboard
    }

}

extension Piece {
    typealias Direction = Bitboard.Direction
    typealias Orientation = [Direction]
}
