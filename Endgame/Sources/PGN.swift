//
//  PGN.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

import Foundation

/// A representation of Portable Game Notation data.
public struct PGN: Equatable {

    /// The tag pairs for `self`.
    private(set) var tagPairs: [Tag: String]

    /// The moves in standard algebraic notation.
    private(set) var sanMoves: [String]

    /// Create a PGN by parsing `string`.
    ///
    /// - throws: `ParseError` if an error occured while parsing.
    public init(parse string: String) throws {
        self.init()
        if string.isEmpty { return }
        for line in string.splitByNewlines() {

            guard !line.isEscaped else {
                continue
            }

            if line.isTag {
                let stripped = try line._commentsStripped(strings: true)
                let (tag, value) = try stripped._tagPair()
                self.tagPairs[tag] = value
            } else {
                let stripped = try line._commentsStripped(strings: false)
                let (moves, outcome) = try stripped._moves()
                self.sanMoves += moves
                if let outcome = outcome {
                    self.outcome = outcome
                }
            }
        }
    }

    // Create a `PGN` object with `tagPairs` and `moves`.
    public init(tagPairs: [Tag: String] = [:], moves: [String] = []) {
        self.sanMoves = moves
        self.tagPairs = tagPairs
    }

    /// Create PGN with `tagPairs` and `moves`.
    public init(tagPairs: [String: String], moves: [String]) {
        var tags: [Tag: String] = [:]
        for entry in tagPairs {
            guard let tag = Tag(rawValue: entry.key) else { continue }
            tags[tag] = entry.value
        }
        self.init(tagPairs: tags, moves: moves)
    }

    // MARK: - Subscripts

    /// Get or set the value for `tag`.
    public subscript(tag: Tag) -> String? {
        get {
            return tagPairs[tag]
        }
        set {
            tagPairs[tag] = newValue
        }
    }

}

// MARK: - Public Computed Properties and Functions

extension PGN {

    /// The game outcome.
    public var outcome: Outcome? {
        get {
            return self[Tag.result].flatMap(Outcome.init)        }
        set {
            self[Tag.result] = newValue?.description ?? "❊"
        }
    }

    public func exportTagPairs() -> String {

        var result = ""
        var pairs = tagPairs
        for (tag, defaultValue) in Tag.roster {
            if let value = pairs[tag] {
                pairs[tag] = nil
                result += "[\(tag.rawValue) \"\(value)\"]\n"
            } else {
                result += "[\(tag.rawValue) \"\(defaultValue)\"]\n"
            }
        }
        for (tag, value) in pairs {
            result += "[\(tag.rawValue) \"\(value)\"]\n"
        }
        return result

    }

    public var fullMoves: [String] {
        var result = [String]()
        for num in stride(from: 0, to: sanMoves.endIndex, by: 2) {
            let moveNumber = (num + 2) / 2
            var moveString = "\(moveNumber). \(sanMoves[num])"
            if num + 1 < sanMoves.endIndex {
                moveString += " \(sanMoves[num+1])"
            }
            result.append(moveString)
        }
        return result
    }

    public var exportFullMoves: String {
        var result: String = ""
        var line: String = ""
        func append(line: String) { result += (result.isEmpty ? "" : "\n") + line }
        func append(element: String) { line += (line.isEmpty ? "" : " ") + element }
        for element in fullMoves + [self.outcome?.description ?? "❊"] {
            if line.characters.count + element.characters.count < 80 {
                append(element: element)
            } else {
                append(line: line)
                line = "\(element)"
            }
        }
        append(line: line)
        return result
    }

    /// A string representation of `self`.
    /// see https://www.chessclub.com/user/help/pgn-spec
    public func exported() -> String {
        return "\(exportTagPairs)\n\(exportFullMoves)\n"
    }

    // MARK: - Static Properties and Functions

    public static func parse(moves: String) -> [String] {
        do {
            let stripped = try moves._commentsStripped(strings: true)
            let moves = try stripped._moves().moves
            return moves
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
}

extension PGN {

    /// Returns a Boolean value indicating whether two values are equal.
    public static func ==(lhs: PGN, rhs: PGN) -> Bool {
        return lhs.tagPairs == rhs.tagPairs && lhs.sanMoves == rhs.sanMoves
    }

}

public extension String {

    fileprivate func _tagPair() throws -> (PGN.Tag, String) {
        guard characters.last == "]" else {
            throw PGN.ParseError.noClosingBracket(self)
        }
        let startIndex = index(after: self.startIndex)
        let endIndex = index(before: self.endIndex)
        let tokens = self[startIndex ..< endIndex].split(by: ["\""])
        guard tokens.count == 2 else {
            throw PGN.ParseError.tagPairTokenCount(tokens)
        }
        let tagParts = tokens[0].splitByWhitespaces()
        guard tagParts.count == 1 else {
            throw PGN.ParseError.tagPairTokenCount(tagParts)
        }
        guard let tag = PGN.Tag(rawValue: tagParts[0]) else {
            throw PGN.ParseError.invalidTagName(tagParts[0])
        }
        return (tag, tokens[1])
    }

    fileprivate func _moves() throws -> (moves: [String], outcome: Outcome?) {
        var stripped = ""
        var depth = 0
        var start = self.startIndex
        for (index, character) in zip(characters.indices, characters) {
            if character == "(" {
                if depth == 0 {
                    stripped += self[start ..< index]
                }
                depth += 1
            } else if character == ")" {
                depth -= 1
                if depth == 0 {
                    start = self.index(after: index)
                }
            } else if index == lastIndex && depth == 0 {
                stripped += self[start ... index]
            }
        }
        guard depth == 0 else {
            throw PGN.ParseError.parenthesisCountForRAV(self)
        }
        let tokens = stripped.split(by: [" ", "."])
        let outcomes = Outcome.all.map { $0.description }
        let moves = tokens.filter { $0.characters.first?.isDigit == false && !outcomes.contains($0) }
        let outcome = tokens.last.flatMap(Outcome.init)
        return (moves, outcome)
    }

    fileprivate func _commentsStripped(strings consideringStrings: Bool) throws -> String {

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
    
}

