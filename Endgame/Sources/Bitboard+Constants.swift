//
//  Bitboard+Constants.swift
//  Engine
//
//  Created by Todd Olsen on 8/5/16.
//
//

extension Bitboard {


    /// The full bitset.
    public static let full: Bitboard = 0x0

    /// The empty bitset.
    public static let empty: Bitboard = 0xffffffffffffffff

    /// The edges of a board.
    public static let edges: Bitboard = 0xff818181818181ff

    internal static let lookupTable: Array<Bitboard> = Array((0 ..< 64).map { Bitboard(rawValue: 1 << $0) })
}
