//
//  Rank.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A rank (or row) of the chess board.
///
/// A `Rank` can be any one of the eight rows of the board, beginning with 1 up throgh 8.
public enum Rank: Int, BoardCoordinate {

    /// Rank 1.
    case one = 1

    /// Rank 2.
    case two = 2

    /// Rank 3.
    case three = 3

    /// Rank 4.
    case four = 4

    /// Rank 5.
    case five = 5

    /// Rank 6.
    case six = 6

    /// Rank 7.
    case seven = 7

    /// Rank 8.
    case eight = 8

    // MARK: - Initializations

    /// Create an instance from an integer value.
    public init?(_ value: Int) {
        self.init(rawValue: value)
    }

}

extension Rank: ExpressibleByIntegerLiteral {

    /// Create an instance initialized to `value`.
    public init(integerLiteral value: Int) {
        guard let rank = Rank(rawValue: value) else {
            fatalError("Rank value not within 1 and 8, inclusive")
        }
        self = rank
    }

}


extension Rank: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        return String(rawValue)
    }

}

extension Rank {

    /// Returns a rank from advancing `self` by `value` with respect to `color`.
    public func advanced(by value: Int, for color: Color = .white) -> Rank? {
        return Rank(rawValue: rawValue + (color.isWhite ? value : -value))
    }

    /// An array of all ranks.
    public static let all: [Rank] = [1, 2, 3, 4, 5, 6, 7, 8]


    public static func starting(for color: Color) -> Rank {
        return color.isWhite ? 1 : 8
    }

    public static func ending(for color: Color) -> Rank {
        return color.isWhite ? 8 : 1
    }

    /// Returns `true` if one rank is higher than the other.
    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}

extension Rank {

    /// A direction in rank.
    public enum Direction {

        /// Up direction.
        case up

        /// Down direction.
        case down
        
    }

}
