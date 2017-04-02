//
//  String+Chess.swift
//  Endgame
//
//  Created by Todd Olsen on 8/6/16.
//
//

public extension String {

    /// The index of the last character in `self`, just before `endeIndex`.
    /// Will crash if `self.isEmpty`.
    public var lastIndex: Index {
        return index(before: endIndex)
    }

    public func split(by set: Set<Character>) -> [String] {
        return characters.split(whereSeparator: set.contains).map(String.init)
    }

    public func splitByNewlines() -> [String] {
        return split(by: Character.newlines)
    }

    public func splitByWhitespaces() -> [String] {
        return split(by: Character.whitespaces)
    }

    public func splitByComma() -> [String] {
        return split(by: Character.comma)
    }

    public func splitBySemicolon() -> [String] {
        return split(by: Character.semicolon)
    }
}

extension String {

    var isTag: Bool {
        return hasPrefix("[")
    }

    var isEscaped: Bool {
        return hasPrefix("%")
    }

    public func strippedComments(consideringStrings: Bool) throws -> String {
        var result = ""
        var _start = startIndex
        var isEscaped = false
        var inString = false
        var inComment = false

        for (index, character) in zip(characters.indices, characters) {

            if character.escape {
                isEscaped = true
                continue
            }

            if character.comment {
                if !inComment {
                    guard consideringStrings else {
                        throw PGN.ParseError.unexpectedQuote(self)
                    }
                    if !inString {
                        inString = true
                    } else if !isEscaped {
                        inString = false
                    }
                }
            } else if !inString {
                if character.restOfLineComment && !inComment {
                    result += self[_start ..< index]
                    break
                } else if character.openBracedComment && !inComment {
                    inComment = true
                    result += self[_start ..< index]
                } else if character.closeBracedComment {
                    guard inComment else {
                        throw PGN.ParseError.unexpectedClosingBrace(self)
                    }
                    inComment = false
                    _start = self.index(after: index)
                }
            }
            if index >= _start && index == lastIndex && !inComment {
                result += self[_start ... index]
            }
            isEscaped = false
        }
        guard !inString else {
            throw PGN.ParseError.noClosingQuote(self)
        }
        guard !inComment else {
            throw PGN.ParseError.noClosingBrace(self)
        }
        return result
    }

    public func moves() throws -> [String] {
        let tokens = self.split(by: [" ", "."])
        let outcomes = Outcome.all.map { $0.description }
        return tokens.filter { $0.characters.first?.isDigit == false && !outcomes.contains($0) }
    }

    public func outcome() throws -> Outcome? {
        if hasSuffix(Outcome.whiteWin.description) {
            return Outcome.win(.white)
        } else if hasSuffix(Outcome.blackWin.description) {
            return Outcome.win(.black)
        } else if hasSuffix(Outcome.draw.description) {
            return Outcome.draw
        } else if hasSuffix("*") {
            return nil
        }
        throw PGN.ParseError.invalidGameTerminationMarker
    }

    public func strippedRAV() throws -> String {
        var result = ""
        var depth = 0
        var start = self.startIndex
        for (index, character) in zip(characters.indices, characters) {
            if character == "(" {
                if depth == 0 {
                    result += self[start ..< index]
                }
                depth += 1
            } else if character == ")" {
                depth -= 1
                if depth == 0 {
                    start = self.index(after: index)
                }
            } else if index == lastIndex && depth == 0 {
                result += self[start ... index]
            }
        }
        guard depth == 0 else {
            throw PGN.ParseError.parenthesisCountForRAV(self)
        }
        return result
    }

    /// Returns `self` parsed into a string of `SAN` moves.
    /// This function does not return 
    func parsedMovetext() throws ->  (moves: [String], outcome: Outcome?) {
        let stripped = try strippedRAV()
        let moves = try stripped.moves()
        let outcome = try stripped.outcome()
        return (moves, outcome)
    }

}

extension Character {

    var escape: Bool {
        return self == "\\"
    }

    var comment: Bool {
        return self == "\""
    }

    var restOfLineComment: Bool {
        return self == ";"
    }

    var openBracedComment: Bool {
        return self == "{"
    }

    var closeBracedComment: Bool {
        return self == "}"
    }

}


/// Extensions to `Character` needed in order to avoid using `CharacterSet` which is Foundation-only.
public extension Character {

    static let newlines: Set<Character> = ["\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}",
                                           "\u{0085}", "\u{2028}", "\u{2029}"]

    static let whitespaces: Set<Character> = ["\u{0020}", "\u{00A0}", "\u{1680}", "\u{180E}", "\u{2000}",
                                              "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}",
                                              "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}",
                                              "\u{200B}", "\u{202F}", "\u{205F}", "\u{3000}", "\u{FEFF}"]

    static let newlinesAndWhitespaces: Set<Character> = Character.newlines.union(Character.whitespaces)

    static let digits: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    static let comma: Set<Character> = [","]

    static let semicolon: Set<Character> = [";"]

    var isDigit: Bool {
        return Character.digits.contains(self)
    }
    
}
