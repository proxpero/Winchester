//
//  Position+Castle.swift
//  Endgame
//
//  Created by Todd Olsen on 3/26/17.
//
//

extension Position {

    /// The castling rights of a chess game.
    public struct Castle {

        /// The rights.
        fileprivate var rights: Set<Right>

    }
}

extension Position.Castle {

    /// Creates empty rights.
    public init() {
        self.rights = Set()
    }

    /// Creates a `Castle` from a `String`.
    ///
    /// - returns: `nil` if `string` is empty or invalid.
    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            self.rights = Set()
        } else {
            var rights = Set<Right>()
            for char in string.characters {
                guard let right = Right(character: char) else {
                    return nil
                }
                rights.insert(right)
            }
            self.rights = rights
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
            self.rights = set
        } else {
            self.rights = Set(sequence)
        }
    }

}

extension Position.Castle {

    /// Returns `true` if `self` can castle for `color`.
    public func canCastle(for color: Color) -> Bool {
        return !self.intersection(Position.Castle(color: color)).isEmpty
    }

    /// Returns `true` if `self` can castle for `side`.
    public func canCastle(for side: Board.Side) -> Bool {
        return !self.intersection(Position.Castle(side: side)).isEmpty
    }

}

extension Position.Castle {

    /// All castling rights.
    public static let all = Position.Castle(Right.all)

    /// White castling rights.
    public static let white = Position.Castle(Right.white)

    /// Black castling rights.
    public static let black = Position.Castle(Right.black)

    /// Kingside castling rights.
    public static let kingside = Position.Castle(Right.kingside)

    /// Queenside castling rights.
    public static let queenside = Position.Castle(Right.queenside)

}

extension Position.Castle: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        if !rights.isEmpty {
            return String(rights.map({ $0.character }).sorted())
        } else {
            return "-"
        }
    }
}

extension Position.Castle: Hashable {

    /// The hash value.
    public var hashValue: Int {
        return rights.reduce(0) { $0 | $1.hashValue }
    }

}

extension Position.Castle: Equatable {

    /// Returns `true` if both have the same rights.
    public static func == (lhs: Position.Castle, rhs: Position.Castle) -> Bool {
        return lhs.rights == rhs.rights
    }

}

extension Position.Castle: Sequence {

    /// An iterator over the members of `Position.Castle`.
    public struct Iterator: IteratorProtocol {

        internal var rightsSet: SetIterator<Right>

        /// Advance to the next element and return it, or `nil` if no next element exists.
        public mutating func next() -> Right? {
            return rightsSet.next()
        }
    }

    /// Returns an iterator over the members.
    public func makeIterator() -> Iterator {
        return Iterator(rightsSet: rights.makeIterator())
    }

}

extension Position.Castle: SetAlgebra {

    /// A Boolean value that indicates whether the set has no elements.
    public var isEmpty: Bool {
        return rights.isEmpty
    }

    /// Returns a Boolean value that indicates whether the given element exists
    /// in the set.
    public func contains(_ member: Right) -> Bool {
        return rights.contains(member)
    }

    /// Returns a new set with the elements of both this and the given set.
    public func union(_ other: Position.Castle) -> Position.Castle {
        return Position.Castle(rights.union(other.rights))
    }

    /// Returns a new set with the elements that are common to both this set and
    /// the given set.
    public func intersection(_ other: Position.Castle) -> Position.Castle {
        return Position.Castle(rights.intersection(other.rights))
    }

    /// Returns a new set with the elements that are either in this set or in the
    /// given set, but not in both.
    public func symmetricDifference(_ other: Position.Castle) -> Position.Castle {
        return Position.Castle(rights.symmetricDifference(other.rights))
    }

    /// Inserts the given element in the set if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: Right) -> (inserted: Bool, memberAfterInsert: Right) {
        return rights.insert(newMember)
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func remove(_ member: Right) -> Right? {
        return rights.remove(member)
    }

    /// Inserts the given element into the set unconditionally.
    @discardableResult
    public mutating func update(with newMember: Right) -> Right? {
        return rights.update(with: newMember)
    }

    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: Position.Castle) {
        rights.formUnion(other.rights)
    }

    /// Removes the elements of this set that aren't also in the given set.
    public mutating func formIntersection(_ other: Position.Castle) {
        rights.formIntersection(other.rights)
    }

    /// Removes the elements of the set that are also in the given set and
    /// adds the members of the given set that are not already in the set.
    public mutating func formSymmetricDifference(_ other: Position.Castle) {
        rights.formSymmetricDifference(other.rights)
    }

    /// Returns a new set containing the elements of this set that do not occur
    /// in the given set.
    public func subtracting(_ other: Position.Castle) -> Position.Castle {
        return Position.Castle(rights.subtracting(other.rights))
    }

    /// Returns a Boolean value that indicates whether the set is a subset of
    /// another set.
    public func isSubset(of other: Position.Castle) -> Bool {
        return rights.isSubset(of: other.rights)
    }

    /// Returns a Boolean value that indicates whether the set has no members in
    /// common with the given set.
    public func isDisjoint(with other: Position.Castle) -> Bool {
        return rights.isDisjoint(with: other.rights)
    }

    /// Returns a Boolean value that indicates whether the set is a superset of
    /// the given set.
    public func isSuperset(of other: Position.Castle) -> Bool {
        return rights.isSuperset(of: other.rights)
    }

    /// Removes the elements of the given set from this set.
    public mutating func subtract(_ other: Position.Castle) {
        rights.subtract(other)
    }

}

