//
//  AsciiConvertible.swift
//  Endgame
//
//  Created by Todd Olsen on 8/5/16.
//
//

public protocol AsciiConvertible {
    /// An ASCII art representation of `self`.
    var ascii: String { get }
}

extension Bitboard: AsciiConvertible {

    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        let ranks = Rank.all.reversed()
        for rank in ranks {
            let strings = File.all.map({ file in self[(file, rank)] ? "1" : "." })
            let str = strings.joined(separator: " ")
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
    }

}

extension Board: AsciiConvertible {

    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        let reversed = Rank.all.reversed()
        for rank in reversed {
            let strings = File.all.map({ file in "\(self[(file, rank)]?.character ?? ".")" })
            let str = strings.joined(separator: " ")
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
    }
    
}
