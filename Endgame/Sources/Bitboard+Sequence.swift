//
//  Bitboard+Sequence.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Bitboard: Sequence {

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

    /// The number of bits set in `self`.
    var count: Int {
        return rawValue.count
    }

    /// `true` if `self` is empty.
    var isEmpty: Bool {
        return self == 0
    }

    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// - complexity: O(1).
    func contains(_ element: Square) -> Bool {
        return self[element]
    }
    
    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - complexity: O(1).
    public var underestimatedCount: Int {
        return count
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
    private var msb: Bitboard {
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
