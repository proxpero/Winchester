//
//  ECO.swift
//  Endgame
//
//  Created by Todd Olsen on 9/25/16.
//
//

import Foundation

/// A model of a chess opening, according to the standards of the Encyclopedia of Chess Openeings.
/// https://en.wikipedia.org/wiki/Encyclopaedia_of_Chess_Openings

public struct ECO {
    
    public let code: Code
    public let name: String
    public let moves: String

    public init?(code: String, name: String, moves: String) {
        guard let c = Code(rawValue: code) else {
            return nil
        }
        self.code = c
        self.name = name
        self.moves = moves
    }

    public init?(sanMoves: String) {
        self = ECO.all[0]
    }
}

extension ECO: Hashable {

    /// Hashable conformance.
    public var hashValue: Int {
        return code.hashValue ^ name.hashValue
    }

}

extension ECO: Equatable {

    /// Equatable conformance.
    public static func == (lhs: ECO, rhs: ECO) -> Bool {
        return lhs.code == rhs.code && lhs.name == rhs.name && lhs.moves == rhs.moves
    }

}

extension ECO {

    static func eco(for moves: String) -> ECO {
        return ECO.all[0]
    }

    public static let all: [ECO] = {
        let url = Bundle(for: Game.self).url(forResource: "ECO", withExtension: "txt")!
        return try! String(contentsOf: url).split(by: Character.newlines)
            .map { $0
                .trimmingCharacters(in: CharacterSet.whitespaces)
                .components(separatedBy: "\t") }
            .flatMap { ECO(code: $0[0],
                           name: $0[1],
                           moves: $0[2].trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet.punctuationCharacters))) }
    }()

    public static let codes: [String: ECO] = {
        var result = [String: ECO]()
        ECO.all.forEach { result[$0.moves.stripped] = $0 }
        return result
    }()

}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        return fromIndex ..< toIndex
    }
}

extension String {
    var stripped: String {
        let regex = try! NSRegularExpression(pattern: "[0-9]*\\.", options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
        var result = self
        for match in matches.reversed() {
            result = result.replacingCharacters(in: match.range.range(for: result)!, with: "")
        }
        return result
    }
}


