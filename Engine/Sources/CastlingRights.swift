//
//  CastlingRights.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// The castling rights of a chess game.
public struct CastlingRights: CustomStringConvertible, Hashable, Equatable, Sequence, SetAlgebra {

    // MARK: -

    /// A castling right.
    public enum Right: String, CustomStringConvertible {

        // MARK: - Cases

        /// White can castle kingside.
        case whiteKingside

        /// White can castle queenside.
        case whiteQueenside

        /// Black can castle kingside.
        case blackKingside

        /// Black can castle queenside.
        case blackQueenside

        // MARK: - Initializers

        /// Create a `Right` from `color` and `side`.
        public init(color: Color, side: Board.Side) {
            switch (color, side) {
            case (.white, .kingside):  self = .whiteKingside
            case (.white, .queenside): self = .whiteQueenside
            case (.black, .kingside):  self = .blackKingside
            case (.black, .queenside): self = .blackQueenside
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

        // MARK: - Computed Properties and Functions

        /// The color for `self`.
        public var color: Color {
            get {
                switch self {
                case .whiteKingside, .whiteQueenside:
                    return .white
                default:
                    return .black
                }
            }
            set {
                self = Right(color: newValue, side: side)
            }
        }

        /// The board side for `self`.
        public var side: Board.Side {
            get {
                switch self {
                case .whiteKingside, .blackKingside:
                    return .kingside
                default:
                    return .queenside
                }
            }
            set {
                self = Right(color: color, side: side)
            }
        }

        /// The squares expected to be empty for a castle.
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
            case .whiteKingside:  return "K"
            case .whiteQueenside: return "Q"
            case .blackKingside:  return "k"
            case .blackQueenside: return "q"
            }
        }

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

        internal var _bit: Int {
            switch self {
            case .whiteKingside:  return 0b0001
            case .whiteQueenside: return 0b0010
            case .blackKingside:  return 0b0100
            case .blackQueenside: return 0b1000
            }
        }

        // MARK: - Public Static Properties and Functions

        /// All rights.
        public static let all: [Right] = [.whiteKingside, .whiteQueenside, .blackKingside, .blackQueenside]

        /// White rights.
        public static let white: [Right] = all.filter { $0.color.isWhite }

        /// Black rights.
        public static let black: [Right] = all.filter { $0.color.isBlack }

        /// Kingside rights.
        public static let kingside: [Right] = all.filter { $0.side.isKingside }
        
        /// Queenside rights.
        public static let queenside: [Right] = all.filter { $0.side.isQueenside }
        
    }

    // MARK: Stored Properties

    /// The rights.
    private var _rights: Set<Right>

    // MARK: Initialization

    /// Creates empty rights.
    public init() {
        _rights = Set()
    }

    /// Creates a `CastlingRights` from a `String`.
    ///
    /// - returns: `nil` if `string` is empty or invalid.
    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            _rights = Set()
        } else {
            var rights = Set<Right>()
            for char in string.characters {
                guard let right = Right(character: char) else {
                    return nil
                }
                rights.insert(right)
            }
            _rights = rights
        }
    }

    /// Creates castling rights for `color`.
    public init(color: Color) {
        self = color.isWhite ? .white : .black
    }

    /// Creates castling rights for `side`.
    public init(side: Board.Side) {
        self = side.isKingside ? .kingside : .queenside
    }

    /// Creates a set of rights from a sequence.
    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Right {
        if let set = sequence as? Set<Right> {
            _rights = set
        } else {
            _rights = Set(sequence)
        }
    }

    // MARK: - Computed Properties and Functions

    /// Returns `true` if `self` can castle for `color`.
    public func canCastle(for color: Color) -> Bool {
        return !self.intersection(CastlingRights(color: color)).isEmpty
    }

    /// Returns `true` if `self` can castle for `side`.
    public func canCastle(for side: Board.Side) -> Bool {
        return !self.intersection(CastlingRights(side: side)).isEmpty
    }

    // MARK: - Public Static Properties and Functions

    /// All castling rights.
    public static let all = CastlingRights(Right.all)

    /// White castling rights.
    public static let white = CastlingRights(Right.white)

    /// Black castling rights.
    public static let black = CastlingRights(Right.black)

    /// Kingside castling rights.
    public static let kingside = CastlingRights(Right.kingside)

    /// Queenside castling rights.
    public static let queenside = CastlingRights(Right.queenside)

    // MARK: - CustomStringConvertible Protocol Conformance

    /// A textual representation of `self`.
    public var description: String {
        if !_rights.isEmpty {
            return String(_rights.map({ $0.character }).sorted())
        } else {
            return "-"
        }
    }

    // MARK: - Hashable Protocol Conformance

    /// The hash value.
    public var hashValue: Int {
        return _rights.reduce(0) { $0 | $1._bit }
    }

    // MARK: - Equatable Protocol Conformance

    /// Returns `true` if both have the same rights.
    public static func == (lhs: CastlingRights, rhs: CastlingRights) -> Bool {
        return lhs._rights == rhs._rights
    }

    // MARK: - Sequence Protocol Conformance

    /// An iterator over the members of `CastlingRights`.
    public struct Iterator: IteratorProtocol {

        internal var rightsSet: SetIterator<Right>

        /// Advance to the next element and return it, or `nil` if no next element exists.
        public mutating func next() -> Right? {
            return rightsSet.next()
        }
    }

    /// Returns an iterator over the members.
    public func makeIterator() -> Iterator {
        return Iterator(rightsSet: _rights.makeIterator())
    }

    // MARK: - SetAlgebra Protocol Conformance

    /// A Boolean value that indicates whether the set has no elements.
    public var isEmpty: Bool {
        return _rights.isEmpty
    }

    /// Returns a Boolean value that indicates whether the given element exists
    /// in the set.
    public func contains(_ member: Right) -> Bool {
        return _rights.contains(member)
    }

    /// Returns a new set with the elements of both this and the given set.
    public func union(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.union(other._rights))
    }

    /// Returns a new set with the elements that are common to both this set and
    /// the given set.
    public func intersection(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.intersection(other._rights))
    }

    /// Returns a new set with the elements that are either in this set or in the
    /// given set, but not in both.
    public func symmetricDifference(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.symmetricDifference(other._rights))
    }

    /// Inserts the given element in the set if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: Right) -> (inserted: Bool, memberAfterInsert: Right) {
        return _rights.insert(newMember)
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func remove(_ member: Right) -> Right? {
        return _rights.remove(member)
    }

    /// Inserts the given element into the set unconditionally.
    @discardableResult
    public mutating func update(with newMember: Right) -> Right? {
        return _rights.update(with: newMember)
    }

    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: CastlingRights) {
        _rights.formUnion(other._rights)
    }

    /// Removes the elements of this set that aren't also in the given set.
    public mutating func formIntersection(_ other: CastlingRights) {
        _rights.formIntersection(other._rights)
    }

    /// Removes the elements of the set that are also in the given set and
    /// adds the members of the given set that are not already in the set.
    public mutating func formSymmetricDifference(_ other: CastlingRights) {
        _rights.formSymmetricDifference(other._rights)
    }

    /// Returns a new set containing the elements of this set that do not occur
    /// in the given set.
    public func subtracting(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.subtracting(other._rights))
    }

    /// Returns a Boolean value that indicates whether the set is a subset of
    /// another set.
    public func isSubset(of other: CastlingRights) -> Bool {
        return _rights.isSubset(of: other._rights)
    }

    /// Returns a Boolean value that indicates whether the set has no members in
    /// common with the given set.
    public func isDisjoint(with other: CastlingRights) -> Bool {
        return _rights.isDisjoint(with: other._rights)
    }

    /// Returns a Boolean value that indicates whether the set is a superset of
    /// the given set.
    public func isSuperset(of other: CastlingRights) -> Bool {
        return _rights.isSuperset(of: other._rights)
    }

    /// Removes the elements of the given set from this set.
    public mutating func subtract(_ other: CastlingRights) {
        _rights.subtract(other)
    }

}

