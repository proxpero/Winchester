//
//  Position+Castle+Right.swift
//  Endgame
//
//  Created by Todd Olsen on 3/26/17.
//
//

extension Position.Castle {

    /// A castling right.
    public enum Right: String {

        /// White can castle kingside.
        case whiteKingside

        /// White can castle queenside.
        case whiteQueenside

        /// Black can castle kingside.
        case blackKingside

        /// Black can castle queenside.
        case blackQueenside

        /// Create a `Right` from `color` and `side`.
        public init(color: Color, side: Board.Side) {
            switch (color, side) {
            case (.white, .kingside):
                self = .whiteKingside
            case (.white, .queenside):
                self = .whiteQueenside
            case (.black, .kingside):
                self = .blackKingside
            case (.black, .queenside):
                self = .blackQueenside
            }
        }

        /// Create a `Right` from a `Character`.
        public init?(character: Character) {
            switch character {
            case "K": self = .whiteKingside
            case "Q": self = .whiteQueenside
            case "k": self = .blackKingside
            case "q": self = .blackQueenside
            default: return nil
            }
        }

    }
}

extension Position.Castle.Right: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }

}

extension Position.Castle.Right: Hashable {

    /// The hash value
    public var hashValue: Int {
        switch self {
        case .whiteKingside:  return 0b0001
        case .whiteQueenside: return 0b0010
        case .blackKingside:  return 0b0100
        case .blackQueenside: return 0b1000
        }
    }

}

extension Position.Castle.Right {

    /// The color for `self`.
    public var color: Color {
        switch self {
        case .whiteKingside, .whiteQueenside:
            return .white
        default:
            return .black
        }
    }

    /// The board side for `self`.
    public var side: Board.Side {
        switch self {
        case .whiteKingside, .blackKingside:
            return .kingside
        default:
            return .queenside
        }
    }

    /// The squares required to be empty for a valid castle move.
    public var emptySquares: Bitboard {
        switch self {
        case .whiteKingside:
            return 0b01100000
        case .whiteQueenside:
            return 0b00001110
        case .blackKingside:
            return 0b01100000 << 56
        case .blackQueenside:
            return 0b00001110 << 56
        }
    }

    /// The castle destination square of a king.
    public var castleSquare: Square {
        switch self {
        case .whiteKingside:
            return .g1
        case .whiteQueenside:
            return .c1
        case .blackKingside:
            return .g8
        case .blackQueenside:
            return .c8
        }
    }

    /// The character for `self`.
    public var character: Character {
        switch self {
        case .whiteKingside:
            return "K"
        case .whiteQueenside:
            return "Q"
        case .blackKingside:
            return "k"
        case .blackQueenside:
            return "q"
        }
    }

    /// All rights.
    public static let all: [Position.Castle.Right] = [.whiteKingside, .whiteQueenside, .blackKingside, .blackQueenside]

    /// White rights.
    public static let white: [Position.Castle.Right] = all.filter { $0.color.isWhite }

    /// Black rights.
    public static let black: [Position.Castle.Right] = all.filter { $0.color.isBlack }

    /// Kingside rights.
    public static let kingside: [Position.Castle.Right] = all.filter { $0.side.isKingside }

    /// Queenside rights.
    public static let queenside: [Position.Castle.Right] = all.filter { $0.side.isQueenside }

}
