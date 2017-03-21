//
//  Piece+Kind.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Piece {

    /// A piece kind.
    public enum Kind: Int {

        /// Pawn piece kind.
        case pawn

        /// Knight piece kind.
        case knight

        /// Bishop piece kind.
        case bishop

        /// Rook piece kind.
        case rook

        /// Queen piece kind.
        case queen

        /// King piece kind.
        case king

        // MARK: Initializers

        /// Creates an `Kind` instance
        ///
        /// - parameter character: a character representation of `Piece.Kind`,
        /// as you might see, for example, in PGN moves.
        public init?(character: Character) {
            switch character {
            case "N": self = .knight
            case "B": self = .bishop
            case "R": self = .rook
            case "Q": self = .queen
            case "K": self = .king
            default:
                return nil
            }
        }

        // MARK: Public Computed Properties

        /// The piece kind's name.
        public var name: String {
            switch self {
            case .pawn:   return "Pawn"
            case .knight: return "Knight"
            case .bishop: return "Bishop"
            case .rook:   return "Rook"
            case .queen:  return "Queen"
            case .king:   return "King"
            }
        }

        /**
         The piece kind's character, as you might see in PGN moves.
         */
        public var character: Character? {
            switch self {
            case .pawn: return nil
            case .knight: return "N"
            case .bishop: return "B"
            case .rook: return "R"
            case .queen: return "Q"
            case .king: return "K"
            }
        }

        /// The piece kind's relative value. Can be used to determine how valuable a piece or combination of pieces is.
        public var relativeValue: Double {
            switch self {
            case .pawn:   return 1
            case .knight: return 3
            case .bishop: return 3.25
            case .rook:   return 5
            case .queen:  return 9
            case .king:   return .infinity
            }
        }

        /// An array of all piece kinds.
        public static let all: [Kind] = [.pawn, .knight, .bishop, .rook, .queen, .king]

        /// The piece is `Pawn`.
        public var isPawn: Bool {
            return self == .pawn
        }

        /// The piece `Knight`.
        public var isKnight: Bool {
            return self == .knight
        }

        /// The piece is `Bishop`.
        public var isBishop: Bool {
            return self == .bishop
        }

        /// The piece is `Rook`.
        public var isRook: Bool {
            return self == .rook
        }

        /// The piece is `Queen`.
        public var isQueen: Bool {
            return self == .queen
        }

        /// The piece is `King`.
        public var isKing: Bool {
            return self == .king
        }

        /// Returns `true` if `self` is the kind of piece that
        /// a pawn can be promoted to.
        public var isPromotionType: Bool {
            return !(isPawn || isKing)
        }

        /// Returns `true` if `self` can be a promotion for `other`.
        public func isPromotable(from other: Kind) -> Bool {
            return isPromotionType ? other.isPawn : false
        }

        /// The starting position bitboard for `self`
        public var startingPosition: Bitboard {
            switch self {
            case .pawn: return 0xFF00 as Bitboard
            case .knight: return 0x0042 as Bitboard
            case .bishop: return 0x0024 as Bitboard
            case .rook: return 0x0081 as Bitboard
            case .queen: return 0x0008 as Bitboard
            case .king: return 0x0010 as Bitboard
            }
        }

//        func attacks(for color: Color? = nil) -> Bitboard {
//            switch self {
//            case .pawn:
//                guard let color = color else {
//                    fatalError("Could not generate a pawn attack without a color.")
//                }
//                switch color {
//                case .white:
//                    return shifted(toward: .northeast) | shifted(toward: .northwest)
//                case .black:
//                    return shifted(toward: .southeast) | shifted(toward: .southwest)
//                }
//            }
//        }
    }
}
