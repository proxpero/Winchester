//
//  Bitboard+.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Bitboard: CustomStringConvertible {
    public var description: String {
        let num = String(rawValue, radix: 16)
        let str = repeatElement("0", count: 16 - num.characters.count).joined(separator: "")
        return "Bitboard(0x\(str + num))"
    }
}

extension Bitboard: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}
