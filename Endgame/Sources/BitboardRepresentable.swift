//
//  BitboardRepresentable.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

protocol BitboardConvertible {
    var bitboard: Bitboard { get }
}

extension File: BitboardConvertible {

    var bitboard: Bitboard {
        switch self {
        case .a: return Bitboard(rawValue: 0x0101010101010101)
        case .b: return Bitboard(rawValue: 0x0202020202020202)
        case .c: return Bitboard(rawValue: 0x0404040404040404)
        case .d: return Bitboard(rawValue: 0x0808080808080808)
        case .e: return Bitboard(rawValue: 0x1010101010101010)
        case .f: return Bitboard(rawValue: 0x2020202020202020)
        case .g: return Bitboard(rawValue: 0x4040404040404040)
        case .h: return Bitboard(rawValue: 0x8080808080808080)
        }

    }

}

extension Rank: BitboardConvertible {
    var bitboard: Bitboard {
        return Bitboard(rawValue: 0xFF << (UInt64(self.index) * 8))
    }
}

extension Square: BitboardConvertible {
    public var bitboard: Bitboard {
        return Bitboard.lookupTable[rawValue]
    }
}

extension Move: BitboardConvertible {
    var bitboard: Bitboard {
        return Bitboard(squares: [origin, target])
    }
}

