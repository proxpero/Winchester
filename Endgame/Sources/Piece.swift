//
//  Piece.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess piece.
public struct Piece: Hashable, CustomStringConvertible {

    // MARK: Stored Properties

    /// The piece's kind.
    public var kind: Kind

    /// The piece's color.
    public var color: Color


    // MARK: Static Computed Properties

    /// An array of all pieces.
    public static let all: [Piece] = {
        // Combine every kind of color with every kind of piece.
        return [.white, .black].reduce([]) { pieces, color in
            return pieces + Kind.all.map({ Piece(kind: $0, color: color) })
        }
    }()

    /// An array of all white pieces.
    public static let whitePieces: [Piece] = all.filter({ $0.color.isWhite })

    /// An array of all black pieces.
    public static let blackPieces: [Piece] = all.filter({ $0.color.isBlack })

    /// Returns an array of all pieces for `color`.
    public static func pieces(for color: Color) -> [Piece] {
        switch color {
        case .white: return whitePieces
        case .black: return blackPieces
        }
    }

    // MARK: Instance Computed Properties

    /// The character for the piece. Uppercase if white or lowercase if black.
    public var character: Character {
        switch kind {
        case .pawn:   return color.isWhite ? "P" : "p"
        case .knight: return color.isWhite ? "N" : "n"
        case .bishop: return color.isWhite ? "B" : "b"
        case .rook:   return color.isWhite ? "R" : "r"
        case .queen:  return color.isWhite ? "Q" : "q"
        case .king:   return color.isWhite ? "K" : "k"
        }
    }

    /// A textual representation of `self`.
    public var description: String {
        return "\(kind.name)(\(color))"
    }

    /// The hash value.
    public var hashValue: Int {
        return (kind.hashValue << 1) | color.hashValue
    }

    /// The starting position bitboard of `self`.
    public var startingPositions: Bitboard {
        switch color {
        case .white: return kind.startingPosition
        case .black: return kind.startingPosition << (kind.isPawn ? 40 : 56)
        }
    }

    // MARK: Initialization

    /// Create a piece from an integer value.
    internal init?(value: Int) {
        guard let kind = Kind(rawValue: value >> 1) else {
            return nil
        }
        self.init(kind: kind, color: value & 1 == 0 ? .white : .black)
    }

    /// Create a piece from `kind` and `color`.
    public init(kind: Kind, color: Color) {
        self.kind = kind
        self.color = color
    }

    /// Create a pawn piece with `color`.
    public init(pawn color: Color) {
        self.init(kind: .pawn, color: color)
    }

    /// Create a knight piece with `color`.
    public init(knight color: Color) {
        self.init(kind: .knight, color: color)
    }

    /// Create a bishop piece with `color`.
    public init(bishop color: Color) {
        self.init(kind: .bishop, color: color)
    }

    /// Create a rook piece with `color`.
    public init(rook color: Color) {
        self.init(kind: .rook, color: color)
    }

    /// Create a queen piece with `color`.
    public init(queen color: Color) {
        self.init(kind: .queen, color: color)
    }

    /// Create a king piece with `color`.
    public init(king color: Color) {
        self.init(kind: .king, color: color)
    }

    /// Create a piece from a character.
    public init?(character: Character) {
        switch character {
        case "P": self.init(pawn: .white)
        case "p": self.init(pawn: .black)
        case "N": self.init(knight: .white)
        case "n": self.init(knight: .black)
        case "B": self.init(bishop: .white)
        case "b": self.init(bishop: .black)
        case "R": self.init(rook: .white)
        case "r": self.init(rook: .black)
        case "Q": self.init(queen: .white)
        case "q": self.init(queen: .black)
        case "K": self.init(king: .white)
        case "k": self.init(king: .black)
        default:
            return nil
        }
    }

    // MARK: Instance Functions

    /// Returns `true` if `self` can be a promotion for `other`.
    public func canPromote(_ other: Piece) -> Bool {
        return kind.isPromotable(from: other.kind) && color == other.color
    }

    /// Returns `true` if `self` is the type of piece that can be promoted.
    ///
    /// - paramter color: The color of the piece.
    public func canPromote(_ color: Color) -> Bool {
        return kind.isPromotionType ? self.color == color : false
    }

    /// The special character for the piece.
    public func specialCharacter(background color: Color = .white) -> Character {
        switch kind {
        case .pawn:   return color == self.color ? "♙" : "♟"
        case .knight: return color == self.color ? "♘" : "♞"
        case .bishop: return color == self.color ? "♗" : "♝"
        case .rook:   return color == self.color ? "♖" : "♜"
        case .queen:  return color == self.color ? "♕" : "♛"
        case .king:   return color == self.color ? "♔" : "♚"
        }
    }

    // MARK: Equatable Conformance

    /// Returns `true` if both pieces are the same.
    public static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.kind == rhs.kind && lhs.color == rhs.color
    }

}
