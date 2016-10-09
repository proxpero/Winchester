//
//  Move.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A single chess move.
///
/// A chess move starts at an "origin" `Square` and ends at a "target" `Square`.
public struct Move: Hashable, CustomStringConvertible {

    // MARK: - Stored Properties

    /// The move's start square.
    public var origin: Square

    /// The move's end square.
    public var target: Square

    // MARK: - Initializers

    /// Create a move with origin and target squares.
    public init(origin: Square, target: Square) {
        self.origin = origin
        self.target = target
    }

    public init(_ origin: Square, _ target: Square) {
        self.origin = origin
        self.target = target
    }

    /// Create a move with origin and target locations.
    public init(origin: Location, target: Location) {
        self.origin = Square(location: origin)
        self.target = Square(location: target)
    }

    /// A castle move for `color` in `direction`.
    public init(castle color: Color, side: Board.Side) {
        let rank: Rank = color.isWhite ? 1 : 8
        self = Move(origin: Square(file: .e, rank: rank),
                    target: Square(file: side == .kingside ? .g : .c, rank: rank))
    }

    // MARK: - Computed Properties and Functions

    /// The move's change in file.
    public var fileChange: Int {
        return target.file.rawValue - origin.file.rawValue
    }

    /// The move's change in rank.
    public var rankChange: Int {
        return target.rank.rawValue - origin.rank.rawValue
    }

    /// Returns `true` if the move is a real change in location.
    public var isChange: Bool {
        return origin != target
    }

    /// Return `true` if the move is diagonal.
    public var isDiagonal: Bool {
        let fileChange = self.fileChange
        return fileChange != 0 && abs(fileChange) == abs(rankChange)
    }

    /// Return `true` if the move is horizontal.
    public var isHorizontal: Bool {
        return origin.file != target.file && origin.rank == target.rank
    }

    /// Return `true` if the move is vertical.
    public var isVertical: Bool {
        return origin.file == target.file && origin.rank != target.rank
    }

    /// Return `true` if the move is horizontal or vertical.
    public var isAxial: Bool {
        return isHorizontal || isVertical
    }

    /// Return `true` if the move is leftward.
    public var isLeftward: Bool {
        return target.file < origin.file
    }

    /// Return `true` if the move is rightward.
    public var isRightward: Bool {
        return target.file > origin.file
    }

    /// Return `true` if the move is downward.
    public var isDownward: Bool {
        return target.rank < origin.rank
    }

    /// Return `true` if the move is upward.
    public var isUpward: Bool {
        return target.rank > origin.rank
    }

    /// Return `true` if the move is a knight jump two spaces horizontally and one space vertically, 
    /// or two spaces vertically and one space horizontally.
    public var isKnightJump: Bool {
        let fileChange = abs(self.fileChange)
        let rankChange = abs(self.rankChange)
        return (fileChange == 2 && rankChange == 1)
            || (rankChange == 2 && fileChange == 1)
    }

    /// The move's direction in file, if any.
    public var fileDirection: File.Direction? {
        if self.isLeftward {
            return .left
        } else if self.isRightward {
            return .right
        } else {
            return .none
        }
    }

    /// The move's direction in rank, if any.
    public var rankDirection: Rank.Direction? {
        if self.isUpward {
            return .up
        } else if self.isDownward {
            return .down
        } else {
            return .none
        }
    }

    /// Returns a bool whether the move reaches the end rank for `color`.
    public func reachesEndRank(for color: Color) -> Bool {
        return self.target.rank == Rank.init(endFor: color)
    }

    /// The hash value.
    public var hashValue: Int {
        return origin.hashValue + (target.hashValue << 6)
    }

    /// Returns a move with the target and origin of `self` reversed.
    public func reversed() -> Move {
        return Move(origin: target, target: origin)
    }

    /// Returns the result of rotating `self` 180 degrees.
    public func rotated() -> Move {
        let origin = Square(file: self.origin.file.opposite(),
                            rank: self.origin.rank.opposite())
        let target = Square(file: self.target.file.opposite(),
                            rank: self.target.rank.opposite())
        return Move(origin: origin, target: target)
    }

    /// Returns `true` if `self` is castle move for `color`.
    ///
    /// - parameter color: The color to check the rank against. If `nil`, the rank can be either 1 or 8. The default
    ///                    value is `nil`.
    public func isCastle(for color: Color? = nil) -> Bool {
        let startRank = origin.rank
        if let color = color {
            guard startRank == Rank(startFor: color) else { return false }
        } else {
            guard startRank == 1 || startRank == 8 else { return false }
        }
        let endFile = target.file
        return startRank == target.rank
            && origin.file == .e
            && (endFile == .c || endFile == .g)
    }

    /// Returns the castle squares for a rook.
    public func castleSquares() -> (old: Square, new: Square) {
        let rank = origin.rank
        let movedLeft = self.isLeftward
        let old = Square(file: movedLeft ? .a : .h, rank: rank)
        let new = Square(file: movedLeft ? .d : .f, rank: rank)
        return (old, new)
    }

    // MARK: - Protocol Conformance

    /// A textual representation of `self`.
    public var description: String {
        return "origin: \(origin), target: \(target)"
    }

    /// Returns `true` if both moves are the same.
    public static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.origin == rhs.origin && lhs.target == rhs.target
    }

}
