//
//  Square.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A pair of a chess board `File` and `Rank`.
public typealias Location = (file: File, rank: Rank)

/// A square on the chess board.
public enum Square: Int, CustomStringConvertible, ExpressibleByStringLiteral {

    // MARK: - Cases

    /// A1 square.
    case a1

    /// B1 square.
    case b1

    /// C1 square.
    case c1

    /// D1 square.
    case d1

    /// E1 square.
    case e1

    /// F1 square.
    case f1

    /// G1 square.
    case g1

    /// H1 square.
    case h1

    /// A2 square.
    case a2

    /// B2 square.
    case b2

    /// C2 square.
    case c2

    /// D2 square.
    case d2

    /// E2 square.
    case e2

    /// F2 square.
    case f2

    /// G2 square.
    case g2

    /// H2 square.
    case h2

    /// A3 square.
    case a3

    /// B3 square.
    case b3

    /// C3 square.
    case c3

    /// D3 square.
    case d3

    /// E3 square.
    case e3

    /// F3 square.
    case f3

    /// G3 square.
    case g3

    /// H3 square.
    case h3

    /// A4 square.
    case a4

    /// B4 square.
    case b4

    /// C4 square.
    case c4

    /// D4 square.
    case d4

    /// E4 square.
    case e4

    /// F4 square.
    case f4

    /// G4 square.
    case g4

    /// H4 square.
    case h4

    /// A5 square.
    case a5

    /// B5 square.
    case b5

    /// C5 square.
    case c5

    /// D5 square.
    case d5

    /// E5 square.
    case e5

    /// F5 square.
    case f5

    /// G5 square.
    case g5

    /// H5 square.
    case h5

    /// A6 square.
    case a6

    /// B6 square.
    case b6

    /// C6 square.
    case c6

    /// D6 square.
    case d6

    /// E6 square.
    case e6

    /// F6 square.
    case f6

    /// G6 square.
    case g6

    /// H6 square.
    case h6

    /// A7 square.
    case a7

    /// B7 square.
    case b7

    /// C7 square.
    case c7

    /// D7 square.
    case d7

    /// E7 square.
    case e7

    /// F7 square.
    case f7

    /// G7 square.
    case g7

    /// H7 square.
    case h7

    /// A8 square.
    case a8

    /// B8 square.
    case b8

    /// C8 square.
    case c8

    /// D8 square.
    case d8

    /// E8 square.
    case e8

    /// F8 square.
    case f8

    /// G8 square.
    case g8

    /// H8 square.
    case h8

    // MARK: - Initialization

    /// Create a square from `file` and `rank`.
    public init(file: File, rank: Rank) {
        self.init(rawValue: file.index + (rank.index << 3))!
    }

    /// Create a square from `location`.
    public init(location: Location) {
        self.init(file: location.file, rank: location.rank)
    }

    /// Create a square from `file` and `rank`. Returns `nil` if either is `nil`.
    public init?(file: File?, rank: Rank?) {
        guard let file = file, let rank = rank else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    /// Create a square from `string`.
    public init?(_ string: String) {
        let chars = string.characters
        guard chars.count == 2 else {
            return nil
        }
        guard let file = File(chars.first!) else {
            return nil
        }
        guard let rank = Int(String(chars.last!)).flatMap({ Rank($0) }) else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    /// Create an instance initialized to `value`.
    public init(stringLiteral value: String) {
        guard let square = Square(value) else {
            fatalError("Invalid string for square: \"\(value)\"")
        }
        self = square
    }

    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }

    // MARK: - Computed Properties and Functions

    /// The file of `self`.
    public var file: File {
        get {
            return File(index: rawValue & 7)!
        }
        set(newFile) {
            self = Square(file: newFile, rank: rank)
        }
    }

    /// The rank of `self`.
    public var rank: Rank {
        get {
            return Rank(index: rawValue >> 3)!
        }
        set(newRank) {
            self = Square(file: file, rank: newRank)
        }
    }

    /// The location of `self`.
    public var location: Location {
        get {
            return (file, rank)
        }
        set(newLocation) {
            self = Square(location: newLocation)
        }
    }

    /// The square's color.
    public var color: Color {
        return (file.index & 1 != rank.index & 1) ? .white : .black
    }

    /// Returns moves from the squares in `squares` to `self`.
//    public func targeted<S: Sequence>(by squares: S) -> [Move] where S.Iterator.Element == Square {
//        return squares.moves(to: self)
//    }

    /// Returns moves from `self` to the squares in `squares`.
//    public func moves<S: Sequence>(to squares: S) -> [Move] where S.Iterator.Element == Square {
//        return squares.moves(from: self)
//    }

    // MARK: - Attacks

    /// Returns a bitboard mask of attacks for a king at `self`.
    public func kingAttacks() -> Bitboard {
        return _kingAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a knight at `self`.
    public func knightAttacks() -> Bitboard {
        return _knightAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a piece at `self`.
    ///
    /// - parameter piece: The piece for the attacks.
    /// - parameter stoppers: The pieces stopping a sliding move. The returned bitboard includes the stopped space.
    ///
    /// - seealso: `attackMoves(for:stoppers:)`
    public func attacks(for occupyingPiece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        switch occupyingPiece.kind {
        case .king:
            return kingAttacks()
        case .knight:
            return knightAttacks()
        case .pawn:
            return _pawnAttackTable(for: occupyingPiece.color)[rawValue]
        default:
            return bitmask._attacks(for: occupyingPiece, stoppers: stoppers)
        }
    }

//    /// Returns an array of attack moves for a piece at `self`.
//    ///
//    /// - seealso: `attacks(for:stoppers:)`
//    public func attackMoves(for piece: Piece, stoppers: Bitboard = 0) -> [Move] {
//        return attacks(for: piece, stoppers: stoppers).moves(from: self)
//    }
//
//    /// returns the pushes available to a pawn occupying `self`.
//    private func availablePawnPushes(for color: Color, empty: Bitboard) -> Bitboard {
//        return bitmask._pawnPushes(for: color, empty: empty)
//    }
//
//    /// Returns the attacks available to a pawn occupying `self`.
//    private func availablePawnAttacks(for color: Color) -> Bitboard {
//        return bitmask._pawnAttacks(for: color)
//    }
//
//    /// returns the attacks available to a knight occupying `self`.
//    private func availableKnightAttacks() -> Bitboard {
//        return bitmask._knightAttacks()
//    }
//
//    /// Returns the attacks available to a bishop occupying `self`.
//    private func availableBishopAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
//        return bitmask._bishopAttacks(stoppers: bitboard)
//    }
//
//    /// Return the attacks available to a rook occupying `self`.
//    private func availableRookAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
//        return bitmask._rookAttacks(stoppers: bitboard)
//    }
//
//    /// Return the attacks available to a queen occupying `self`.
//    private func availableQueenAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
//        return bitmask._queenAttacks(stoppers: bitboard)
//    }
//
//    /// Returns the attacks available to a king occupying `self`.
//    private func availableKingAttacks() -> Bitboard {
//        return bitmask._kingAttacks()
//    }

    // MARK: - Static Properties and Functions

    /// An array of all squares.
    public static let all: [Square] = (0 ..< 64).flatMap(Square.init(rawValue:))

    // MARK: - Protocol Conformance

    /// A textual representation of `self`.
    public var description: String {
        return "\(file)\(rank)"
    }

}
