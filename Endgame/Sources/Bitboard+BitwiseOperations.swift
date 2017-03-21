//
//  Bitboard+BitwiseOperations.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Bitboard: BitwiseOperations {

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

}
