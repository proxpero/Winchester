//
//  Bitboard.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A bitmap of sixty-four bits suitable for storing squares for various pieces, where
/// the first bit refers to `Square.A1` and the last (64th) bit refers to `Square.H8`.
public struct Bitboard: RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral, BitwiseOperations, Sequence {

    // MARK: -Nested Types

    /// A bitboard shift direction.
    public enum ShiftDirection {

        // MARK: Cases

        case north
        case south
        case east
        case west
        case northeast
        case southeast
        case northwest
        case southwest
    }

    // MARK: - Stored Properties

    /// The corresponding value of the raw type. The 64 bits of this value
    /// correspond to the 64 squares of the chess board.
    ///
    /// `Self(rawValue: self.rawValue)!` is equivalent to `self`.
    public var rawValue: UInt64

    // MARK: - Initializers

    /// Convert from a raw value of `UInt64`.
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Create an empty bitboard.
    public init() {
        rawValue = 0
    }

    /// Create a bitboard from a sequence of `Square`s.
    public init<S: Sequence>(squares: S) where S.Iterator.Element == Square {
        rawValue = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from a sequence of `Location`s.
    public init<S: Sequence>(locations: S) where S.Iterator.Element == Location {
        self.init(squares: locations.map(Square.init(location:)))
    }

    // MARK: - Subscripts

    /// The `Bool` value for the bit at `square`.
    ///
    /// - complexity: O(1).
    public subscript(square: Square) -> Bool {
        get {
            return intersects(Bitboard.lookupTable[square.rawValue])
        }
        set {
            let bit = square.bitmask
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

    // MARK: - Computed Properties and Functions

    /// The number of bits set in `self`.
    public var count: Int {
        return rawValue.count
    }

    /// `true` if `self` is empty.
    public var isEmpty: Bool {
        return self == 0
    }

    /// Returns `true` if `self` intersects `other`.
    public func intersects(_ other: Bitboard) -> Bool {
        return rawValue & other.rawValue != 0
    }

    /// Returns the ranks of `self` as eight 8-bit integers.
    public func ranks() -> [UInt8] {
        return (0 ..< 8).map { UInt8((rawValue >> ($0 * 8)) & 255) }
    }

    /// Swaps the bits between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// - complexity: O(1).
    public func contains(_ element: Square) -> Bool {
        return self[element]
    }

    // MARK: - Attacks

    /// Returns the pawn pushes available for `color` in `self`.
    internal func _pawnPushes(for color: Color, empty: Bitboard) -> Bitboard {
        return (color.isWhite ? shifted(toward: .north) : shifted(toward: .south)) & empty
    }

    /// Returns the attacks available to the pawns for `color` in `self`.
    internal func _pawnAttacks(for color: Color) -> Bitboard {
        switch color {
        case .white: return shifted(toward: .northeast) | shifted(toward: .northwest)
        case .black: return shifted(toward: .southeast) | shifted(toward: .southwest)
        }
    }

    /// Returns the attacks available to a knight in `self`.
    internal func _knightAttacks() -> Bitboard {
        let x = self
        let a = (((x << 17) | (x >> 15)) & File.notA)
        let b = (((x << 10) | (x >> 06)) & File.notAB)
        let c = (((x << 15) | (x >> 17)) & File.notH)
        let d = (((x << 06) | (x >> 10)) & File.notGH)
        return a | b | c | d
    }

    /// Returns the attacks available to a bishop in `self`.
    internal func _bishopAttacks(obstacles bitboard: Bitboard = 0) -> Bitboard {
        let ne = filled(toward: .northeast, obstacles: bitboard).shifted(toward: .northeast)
        let nw = filled(toward: .northwest, obstacles: bitboard).shifted(toward: .northwest)
        let se = filled(toward: .southeast, obstacles: bitboard).shifted(toward: .southeast)
        let sw = filled(toward: .southwest, obstacles: bitboard).shifted(toward: .southwest)
        return ne | nw | se | sw
    }

    /// Returns the attacks available to a rook in `self`.
    internal func _rookAttacks(obstacles bitboard: Bitboard = 0) -> Bitboard {
        let n = filled(toward: .north, obstacles: bitboard).shifted(toward: .north)
        let s = filled(toward: .south, obstacles: bitboard).shifted(toward: .south)
        let e = filled(toward: .east,  obstacles: bitboard).shifted(toward: .east)
        let w = filled(toward: .west,  obstacles: bitboard).shifted(toward: .west)
        return n | s | e | w
    }

    /// Returns the attacks available to the queen in `self`.
    internal func _queenAttacks(obstacles bitboard: Bitboard = 0) -> Bitboard {
        let rook = _rookAttacks(obstacles: bitboard)
        let bishop = _bishopAttacks(obstacles: bitboard)
        return rook | bishop
    }

    /// Returns the attacks available to the king in `self`.
    internal func _kingAttacks() -> Bitboard {
        let attacks = shifted(toward: .east) | shifted(toward: .west)
        let bitboard = self | attacks
        return attacks
            | bitboard.shifted(toward: .north)
            | bitboard.shifted(toward: .south)
    }

    /// Returns the attacks available to `piece` in `self`.
    internal func _attacks(for piece: Piece, obstacles: Bitboard = 0) -> Bitboard {
        switch piece.kind {
        case .pawn: return _pawnAttacks(for: piece.color)
        case .knight: return _knightAttacks()
        case .bishop: return _bishopAttacks(obstacles: obstacles)
        case .rook: return _rookAttacks(obstacles: obstacles)
        case .queen: return _queenAttacks(obstacles: obstacles)
        case .king: return _kingAttacks()
        }
    }

    // MARK: - Transformations

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

    /// Returns the bits of `self` filled toward `direction` stopped by `obstacles`.
    public func filled(toward direction: ShiftDirection, obstacles: Bitboard) -> Bitboard {
        let empty = ~obstacles
        var bitboard = self
        for _ in 0 ..< 7 {
            bitboard |= empty & bitboard.shifted(toward: direction)
        }
        return bitboard
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    public func shifted(toward direction: ShiftDirection) -> Bitboard {
        switch direction {
        case .north:     return  self << 8
        case .south:     return  self >> 8
        case .east:      return (self << 1) & File.notA
        case .northeast: return (self << 9) & File.notA
        case .southeast: return (self >> 7) & File.notA
        case .west:      return (self >> 1) & File.notH
        case .southwest: return (self >> 9) & File.notH
        case .northwest: return (self << 7) & File.notH
        }
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
    public mutating func shift(toward direction: ShiftDirection) {
        self = shifted(toward: direction)
    }

    /// Fills the bits of `self` toward `direction` stopped by `obstacles`.
    public mutating func fill(toward direction: ShiftDirection, obstacles: Bitboard = 0) {
        self = filled(toward: direction, obstacles: obstacles)
    }

    // MARK: - Protocol Conformance

    // MARK: CustomStringConvertible
    /// A `String` representation of `self`
    public var description: String {
        let num = String(rawValue, radix: 16)
        let str = repeatElement("0", count: 16 - num.characters.count).joined(separator: "")
        return "Bitboard(0x\(str + num))"
    }

    // MARK: Hashable
    /// The has value.
    public var hashValue: Int {
        return rawValue.hashValue
    }

    // MARK: ExpressibleByIntegerLiteral
    /// Create an instance initialized to `value`.
    public init(integerLiteral value: UInt64) {
        rawValue = value
    }

    // MARK: Sequence

    /// An iterator for the squares of a `Bitboard`.
    public struct Iterator: IteratorProtocol {

        private var _bitboard: Bitboard

        init(_ bitboard: Bitboard) {
            self._bitboard = bitboard
        }

        /// Advances and returns the next element of the underlying sequence, or
        /// `nil` if no next element exists.
        public mutating func next() -> Square? {
            return _bitboard.popLSBSquare()
        }
    }

    /// Returns an iterator over the squares of the board.
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - complexity: O(1).
    public var underestimatedCount: Int {
        return count
    }

    // MARK: - Bitwise Operations

    /// The empty bitboard.
    public static var allZeros: Bitboard {
        return Bitboard.empty
    }

    /// Returns the intersection of bits set in `lhs` and `rhs`.
    ///
    /// - complexity: O(1).
    public static func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue & rhs.rawValue)
    }

    /// Returns the union of bits set in `lhs` and `rhs`.
    ///
    /// - complexity: O(1).
    public static func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue | rhs.rawValue)
    }

    /// Returns the bits that are set in exactly one of `lhs` and `rhs`.
    ///
    /// - complexity: O(1).
    public static func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue ^ rhs.rawValue)
    }

    /// Returns `x ^ ~Self.allZeros`.
    ///
    /// - complexity: O(1).
    public static prefix func ~ (x: Bitboard) -> Bitboard {
        return Bitboard(rawValue: ~x.rawValue)
    }

    /// Returns the bits of `lhs` shifted right by `rhs`.
    public static func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue >> rhs.rawValue)
    }

    /// Returns the bits of `lhs` shifted left by `rhs`.
    public static func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue << rhs.rawValue)
    }

    /// Shifts the bits of `lhs` right by `rhs`.
    public static func >>= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs.rawValue >>= rhs.rawValue
    }

    /// Shifts the bits of `lhs` left by `rhs`.
    public static func <<= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs.rawValue <<= rhs.rawValue
    }

    // MARK: - Least and Most Significant Bits

    /// The least significant bit.
    private var lsb: Bitboard {
        return Bitboard(rawValue: rawValue & (0 &- rawValue))
    }

    /// The index for the least significant bit of `self`.
    private var lsbIndex: Int? {
        return lsb._lsbIndex
    }

    /// The square for the least significant bit of `self`.
    public var lsbSquare: Square? {
        return lsbIndex.flatMap({ Square(rawValue: $0) })
    }

    /// Removes the least significant bit and returns it.
    private mutating func popLSB() -> Bitboard {
        let lsb = self.lsb
        rawValue -= lsb.rawValue
        return lsb
    }

    /// Removes the least significant bit and returns its index, if any.
    private mutating func popLSBIndex() -> Int? {
        return popLSB()._lsbIndex
    }

    /// Removes the least significant bit and returns its square, if any.
    private mutating func popLSBSquare() -> Square? {
        return popLSBIndex().flatMap({ Square(rawValue: $0) })
    }

    /// Removes the most significant bit and returns it.
    private mutating func popMSB() -> Bitboard {
        let msb = self.msb
        rawValue -= msb.rawValue
        return msb
    }

    /// Removes the most significant bit and returns its index, if any.
    private mutating func popMSBIndex() -> Int? {
        guard rawValue != 0 else { return nil }
        let shifted = _msbShifted
        rawValue -= (shifted >> 1) + 1
        return Bitboard._msbTable[Int((shifted &* Bitboard._debruijn64) >> 58)]
    }

    /// Removes the most significant bit and returns its square, if any.
    private mutating func popMSBSquare() -> Square? {
        return popMSBIndex().flatMap({ Square(rawValue: $0) })
    }

    private var _msbShifted: UInt64 {
        var x = rawValue
        x |= x >> 1
        x |= x >> 2
        x |= x >> 4
        x |= x >> 8
        x |= x >> 16
        x |= x >> 32
        return x
    }

    /// The most significant bit.
    public var msb: Bitboard {
        return Bitboard(rawValue: (_msbShifted >> 1) + 1)
    }

    /// The index for the most significant bit of `self`.
    private var msbIndex: Int? {
        guard rawValue != 0 else {
            return nil
        }
        return Bitboard._msbTable[Int((_msbShifted &* Bitboard._debruijn64) >> 58)]
    }

    /// The square for the most significant bit of `self`.
    public var msbSquare: Square? {
        return msbIndex.flatMap({ Square(rawValue: $0) })
    }

    /// The De Bruijn multiplier.
    private static let _debruijn64: UInt64 = 0x03f79d71b4cb0a89

    /// Returns the index of the lsb value in the lsb table.
    private var _lsbIndex: Int? {
        guard self != 0 else {
            return nil
        }
        return Bitboard._lsbTable[Int((rawValue &* Bitboard._debruijn64) >> 58)]
    }

    // MARK: - Static Constants

    /// The full bitset.
    public static let full: Bitboard = 0xffffffffffffffff

    /// The empty bitset.
    public static let empty: Bitboard = 0x0

    /// The edges of a board.
    public static let edges: Bitboard = 0xff818181818181ff

    internal static let lookupTable: Array<Bitboard> = Array((0 ..< 64).map { Bitboard(rawValue: 1 << $0) })

    private static let _lsbTable: Array<Int> = [
        00, 01, 48, 02, 57, 49, 28, 03,
        61, 58, 50, 42, 38, 29, 17, 04,
        62, 55, 59, 36, 53, 51, 43, 22,
        45, 39, 33, 30, 24, 18, 12, 05,
        63, 47, 56, 27, 60, 41, 37, 16,
        54, 35, 52, 21, 44, 32, 23, 11,
        46, 26, 40, 15, 34, 20, 31, 10,
        25, 14, 19, 09, 13, 08, 07, 06
    ]

    private static let _msbTable: Array<Int> = [
        00, 47, 01, 56, 48, 27, 02, 60,
        57, 49, 41, 37, 28, 16, 03, 61,
        54, 58, 35, 52, 50, 42, 21, 44,
        38, 32, 29, 23, 17, 11, 04, 62,
        46, 55, 26, 59, 40, 36, 15, 53,
        34, 51, 20, 43, 31, 22, 10, 45,
        25, 39, 14, 33, 19, 30, 09, 24,
        13, 18, 08, 12, 07, 06, 05, 63
    ]

}

// MARK: Free Internal Functions and Computed Properties

/// Returns the pawn attack table for `color`.
internal func _pawnAttackTable(for color: Color) -> Array<Bitboard> {
    let _whitePawnAttackTable = Array(Square.all.map { square in
        return square.bitmask._pawnAttacks(for: .white)
    })
    switch color {
    case .white: return _whitePawnAttackTable
    case .black: return _blackPawnAttackTable
    }
}

/// A lookup table of all white pawn attack bitboards.
internal let _whitePawnAttackTable = Array(Square.all.map { square in
    return square.bitmask._pawnAttacks(for: .white)
})

/// A lookup table of all black pawn attack bitboards.
internal let _blackPawnAttackTable = Array(Square.all.map { square in
    return square.bitmask._pawnAttacks(for: .black)
})

/// A lookup table of all king attack bitboards.
internal let _kingAttackTable = Array(Square.all.map { square in
    return square.bitmask._kingAttacks()
})

/// A lookup table of all knight attack bitboards.
internal let _knightAttackTable = Array(Square.all.map { square in
    return square.bitmask._knightAttacks()
})

// MARK: - Helpers

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

