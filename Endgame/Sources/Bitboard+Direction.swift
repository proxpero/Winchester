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

//    var moveOrientations: [Orientation] {
//        switch kind {
//        case .pawn:
//            switch color {
//            case .white:
//                return [[.north]]
//            case .black:
//                return [[.south]]
//            }
//        case .knight:
//            return [
//                [.north, .north, .northwest],
//                [.north, .north, .northeast],
//                [.east, .east, .northeast],
//                [.east, .east, .southeast],
//                [.south, .south, .southeast],
//                [.south, .south, .southwest],
//                [.west, .west, .southwest],
//                [.west, .west, .southwest]
//            ]
//        case .bishop:
//            return [
//                [.northeast], [.northwest], [.southeast], [.southwest]
//            ]
//
//        case .rook:
//            return [.north]
//        }
//
//
//    }



//    var moveOrientation: Move.Orientation {
//        switch self.kind {
//        case .bishop:
//            return [.diagonal]
//        case .rook:
//            return [.orthogonal]
//        case .queen:
//            return [.diagonal, .orthogonal]
//        default:
//            return []
//        }
//    }
//
//    var isSlider: Bool {
//        switch self.kind {
//        case .bishop, .rook, .queen:
//            return true
//        case .pawn, .knight, .king:
//            return false
//        }
//    }
//
//    var moveDirections: [Bitboard.Direction] {
//
//        switch self.kind {
//        case .bishop:
//            return [.northeast]
//        }
//    }

}



/*

 /// A bitboard shift direction.
 public enum Direction: UInt8 {
 case north     = 0b00000001
 case south     = 0b00000010
 case east      = 0b00000100
 case west      = 0b00001000
 case northeast = 0b00010000
 case southeast = 0b00100000
 case northwest = 0b01000000
 case southwest = 0b10000000
 }

 struct Orientation: OptionSet {
 let rawValue: Direction.RawValue
 static let north     = Orientation(rawValue: Direction.north.rawValue)
 static let northeast = Orientation(rawValue: Direction.northeast.rawValue)
 static let east      = Orientation(rawValue: Direction.east.rawValue)
 static let southeast = Orientation(rawValue: Direction.southeast.rawValue)
 static let south     = Orientation(rawValue: Direction.south.rawValue)
 static let southwest = Orientation(rawValue: Direction.southwest.rawValue)
 static let west      = Orientation(rawValue: Direction.west.rawValue)
 static let northwest = Orientation(rawValue: Direction.northwest.rawValue)

 static let diagonal: Orientation = [.northeast, .northwest, .southeast, .southwest]
 static let orthogonal: Orientation = [.north, .east, .south, .west]
 }

 */
