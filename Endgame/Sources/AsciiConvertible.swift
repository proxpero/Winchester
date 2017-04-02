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
    func asciiCharacter(file: File, rank: Rank) -> String
}

extension AsciiConvertible {

    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        let ranks = Rank.all.reversed()
        for rank in ranks {
            let strings = File.all.map { file in
                return asciiCharacter(file: file, rank: rank)
            }
            let str = strings.joined(separator: " ")
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
    }

}

extension Bitboard: AsciiConvertible {

    public func asciiCharacter(file: File, rank: Rank) -> String {
        return self[(file, rank)] ? "1" : "."
    }

}

extension Board: AsciiConvertible {

    public func asciiCharacter(file: File, rank: Rank) -> String {
        let char = self[(file, rank)]?.character ?? "."
        return String(char)
    }

}
