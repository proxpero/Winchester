//
//  String+Chess.swift
//  Endgame
//
//  Created by Todd Olsen on 8/6/16.
//
//

public extension String {

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



public extension Character {

    static let newlines: Set<Character> = ["\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}",
                                           "\u{0085}", "\u{2028}", "\u{2029}"]

    static let whitespaces: Set<Character> = ["\u{0020}", "\u{00A0}", "\u{1680}", "\u{180E}", "\u{2000}",
                                              "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}",
                                              "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}",
                                              "\u{200B}", "\u{202F}", "\u{205F}", "\u{3000}", "\u{FEFF}"]

    static let digits: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    static let comma: Set<Character> = [","]

    static let semicolon: Set<Character> = [";"]

    var isDigit: Bool {
        return Character.digits.contains(self)
    }
    
}
