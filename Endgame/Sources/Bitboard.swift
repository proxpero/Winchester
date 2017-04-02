//
//  Bitboard.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A bitmap of sixty-four bits suitable for storing squares for various pieces, where
/// the first bit refers to `Square.A1` and the last (64th) bit refers to `Square.H8`.
public struct Bitboard {

    // The UInt64 value of `self`
    fileprivate var _value: UInt64

}

extension Bitboard: RawRepresentable {

    /// The corresponding value of the raw type. The 64 bits of this value
    /// correspond to the 64 squares of the chess board.
    ///
    /// `Self(rawValue: self.rawValue)!` is equivalent to `self`.
    public var rawValue: UInt64 {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }

    /// Convert from a raw value of `UInt64`.
    public init(rawValue: UInt64) {
        self._value = rawValue
    }
    
}

extension Bitboard: ExpressibleByIntegerLiteral {

    /// `ExpressibleByIntegerLiteral` conformance
    public init(integerLiteral value: UInt64) {
        self._value = value
    }

}

extension Bitboard {

    /// Create an empty bitboard.
    public init() {
        self._value = 0
    }

    /// Create a bitboard from a sequence of `Square`s.
    public init<S: Sequence>(squares: S) where S.Iterator.Element == Square {
        _value = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from a sequence of `Location`s.
    public init<S: Sequence>(locations: S) where S.Iterator.Element == Location {
        self.init(squares: locations.map(Square.init(location:)))
    }

}

extension Bitboard {

    /// The `Bool` value for the bit at `square`.
    ///
    /// - complexity: O(1).
    public subscript(square: Square) -> Bool {
        get {
            return intersects(Bitboard.lookupTable[square.rawValue])
        }
        set {
            let bit = square.bitboard
            if newValue {
                rawValue |= bit.rawValue
            } else {
                rawValue &= ~bit.rawValue
            }
        }
    }

    /// The `Bool` value for the bit at `location`.
    ///
    /// - complexity: O(1).
    public subscript(location: Location) -> Bool {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    // MARK: - Transformations

    /// Swaps the bits between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Returns `self` flipped horizontally.
    public func flippedHorizontally() -> Bitboard {
        let x = 0x5555555555555555 as Bitboard
        let y = 0x3333333333333333 as Bitboard
        let z = 0x0F0F0F0F0F0F0F0F as Bitboard
        var n = self
        n = ((n >> 1) & x) | ((n & x) << 1)
        n = ((n >> 2) & y) | ((n & y) << 2)
        n = ((n >> 4) & z) | ((n & z) << 4)
        return n
    }

    /// Returns `self` flipped vertically.
    public func flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as Bitboard
        let y = 0x0000FFFF0000FFFF as Bitboard
        var n = self
        n = ((n >>  8) & x) | ((n & x) <<  8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n =  (n >> 32)      |       (n << 32)
        return n
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Shifts the bits of `self` once toward `direction`.
    mutating func shift(toward direction: Direction) {
        self = shifted(toward: direction)
    }

    /// Fills the bits of `self` toward `direction` stopped by `obstacles`.
    mutating func fill(toward direction: Direction, obstacles: Bitboard = 0) {
        self = filled(toward: direction, until: obstacles)
    }

}

extension Bitboard: CustomStringConvertible {

    /// A String representation of `self`.
    public var description: String {
        let num = String(rawValue, radix: 16)
        let str = repeatElement("0", count: 16 - num.characters.count).joined(separator: "")
        return "Bitboard(0x\(str + num))"
    }
}

extension Bitboard: Hashable {

    /// The hash value.
    public var hashValue: Int {
        return rawValue.hashValue
    }

}

extension UInt64 {
    /// The number of 1s in the binary representation of `self`
    /// http://stackoverflow.com/a/109025/277905
    public var count: Int {
        var n = self
        n = n - ((n >> 1) & 0x5555555555555555)
        n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333)
        return Int((((n + (n >> 4)) & 0xF0F0F0F0F0F0F0F) &* 0x101010101010101) >> 56)
    }
}

