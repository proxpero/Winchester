//
//  Board+Space.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

public typealias Capture = Board.Space

extension Board {

    /// A chess board space encapsulating the square and any piece occupying that square.
    public struct Space {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// Create a chess board space with a piece and location.
        public init(piece: Piece? = nil, location: Location) {
            self.piece = piece
            (file, rank) = location
        }

        /// Create a chess board space with a piece, file, and rank.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.init(piece: piece, location: (file, rank))
        }

        /// Create a chess board space with a piece and square.
        public init(piece: Piece? = nil, square: Square) {
            self.piece = piece
            (file, rank) = square.location
        }

    }

}

extension Board.Space: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        let pieceDescription: String = piece != nil ? "\(piece!.description)" : ""
        return "Space(\(name) \(pieceDescription))"
    }

}

extension Board.Space: Hashable {

    /// The hash value.
    public var hashValue: Int {
        let pieceHash = piece?.hashValue ?? (6 << 1)
        let fileHash = file.hashValue << 4
        let rankHash = rank.hashValue << 7
        return pieceHash + fileHash + rankHash
    }

}

extension Board.Space: Equatable {

    /// Returns `true` if both spaces are the same.
    public static func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
        return lhs.piece == rhs.piece
            && lhs.file == rhs.file
            && lhs.rank == rhs.rank
    }

}

extension Board.Space {

    /// The space's location on a chess board.
    public var location: Location {
        get {
            return (file, rank)
        }
        set {
            (file, rank) = newValue
        }
    }

    /// The space's square on a chess board.
    public var square: Square {
        get {
            return Square(file: file, rank: rank)
        }
        set {
            location = newValue.location
        }
    }

    /// The color of a space's square on the board.
    public var color: Color {
        return (file.index & 1 != rank.index & 1) ? .white : .black
    }

    /// The space's name. For example: "a3".
    public var name: String {
        return "\(file.character)\(rank.rawValue)"
    }

    /// Clears the piece from the space and returns it.
    @discardableResult
    public mutating func clear() -> Piece? {
        let piece = self.piece
        self.piece = nil
        return piece
    }

    
    public func attacks(with obstacles: Bitboard = 0) -> Bitboard {
        guard let piece = piece else { return 0 as Bitboard }
        let origin = square.bitboard

        func diagonalSquares() -> Bitboard {
            let ne = origin
                .filled(toward: .northeast, until: obstacles)
                .shifted(toward: .northeast)
            let nw = origin
                .filled(toward: .northwest, until: obstacles)
                .shifted(toward: .northwest)
            let se = origin
                .filled(toward: .southeast, until: obstacles)
                .shifted(toward: .southeast)
            let sw = origin
                .filled(toward: .southwest, until: obstacles)
                .shifted(toward: .southwest)
            return ne | nw | se | sw
        }

        func orthogonalSquares() -> Bitboard {
            let n = origin
                .filled(toward: .north, until: obstacles)
                .shifted(toward: .north)
            let s = origin
                .filled(toward: .south, until: obstacles)
                .shifted(toward: .south)
            let e = origin
                .filled(toward: .east,  until: obstacles)
                .shifted(toward: .east)
            let w = origin
                .filled(toward: .west,  until: obstacles)
                .shifted(toward: .west)
            return n | s | e | w
        }

        switch piece.kind {

        case .pawn:
            switch piece.color {
            case .white:
                return origin.shifted(toward: .northeast) | origin.shifted(toward: .northwest)
            case .black:
                return origin.shifted(toward: .southeast) | origin.shifted(toward: .southwest)
            }

        case .knight:
            let a = (((origin << 17) | (origin >> 15)) & ~File.a)
            let b = (((origin << 10) | (origin >> 06)) & ~(File.a | File.b))
            let c = (((origin << 15) | (origin >> 17)) & ~File.h)
            let d = (((origin << 06) | (origin >> 10)) & ~(File.g | File.h))
            return a | b | c | d

        case .bishop:
            return diagonalSquares()

        case .rook:
            return orthogonalSquares()

        case .queen:
            return diagonalSquares() | orthogonalSquares()

        case .king:
            let row = origin.shifted(toward: .east) | origin.shifted(toward: .west)
            let bitboard = origin | row
            return row
                | bitboard.shifted(toward: .north)
                | bitboard.shifted(toward: .south)
        }
    }
}

