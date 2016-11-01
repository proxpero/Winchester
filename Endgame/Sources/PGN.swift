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

    // MARK: -

    /// PGN tag.
    public enum Tag: String, CustomStringConvertible {

        // MARK: Cases

        /// Event tag.
        case event = "Event"

        /// Site tag.
        case site = "Site"

        /// Date tag.
        case date = "Date"

        /// Round tag.
        case round = "Round"

        /// White tag.
        case white = "White"

        /// Black tag.
        case black = "Black"

        /// Result tag.
        case result = "Result"

        /// Annotator tag.
        case annotator = "Annotator"

        /// Ply (moves) count tag.
        case plyCount = "PlyCount"

        /// TimeControl tag.
        case timeControl = "TimeControl"

        /// Time tag.
        case time = "Time"

        /// Termination tag.
        case termination = "Termination"

        /// Playing mode tag.
        case mode = "Mode"

        /// FEN tag.
        case fen = "FEN"

        /// White player's title tag.
        case whiteTitle = "WhiteTitle"

        /// Black player's title tag.
        case blackTitle = "BlackTitle"

        /// White player's elo rating tag.
        case whiteElo = "WhiteElo"

        /// Black player's elo rating tag.
        case blackElo = "BlackElo"

        /// White player's United States Chess Federation rating tag.
        case whiteUSCF = "WhiteUSCF"

        /// Black player's United States Chess Federation rating tag.
        case blackUSCF = "BlackUSCF"

        /// White player's network or email address tag.
        case whiteNA = "WhiteNA"

        /// Black player's network or email address tag.
        case blackNA = "BlackNA"

        /// White player's type tag; either human or program.
        case whiteType = "WhiteType"

        /// Black player's type tag; either human or program.
        case blackType = "BlackType"

        /// The starting date tag of the event.
        case eventDate = "EventDate"

        /// Tag for the name of the sponsor of the event.
        case eventSponsor = "EventSponsor"

        /// The playing section tag of a tournament.
        case section = "Section"

        /// Tag for the stage of a multistage event.
        case stage = "Stage"

        /// The board number tag in a team event or in a simultaneous exhibition.
        case board = "Board"

        /// The traditional opening name tag.
        case opening = "Opening"

        /// Tag used to further refine the opening tag.
        case variation = "Variation"

        /// Used to further refine the variation tag.
        case subVariation = "SubVariation"

        /// Tag used for an opening designation from the five volume *Encyclopedia of Chess Openings*.
        case eco = "ECO"

        /// Tag used for an opening designation from the *New in Chess* database.
        case nic = "NIC"

        /// Tag similar to the Time tag but given according to the Universal Coordinated Time standard.
        case utcTime = "UTCTime"

        /// Tag similar to the Date tag but given according to the Universal Coordinated Time standard.
        case utcDate = "UTCDate"

        /// Tag for the "set-up" status of the game.
        case setUp = "SetUp"

        // MARK: CustomStringConvertible Protocol Conformance

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

        public static var roster: [(tag: Tag, default: String)] {
            return [
                (.event, "?"),
                (.site, "?"),
                (.date, "????.??.??"),
                (.round, "?"),
                (.white, "?"),
                (.black, "?"),
                (.result, "?")]
        }

    }

    // MARK: -

    /// An error thrown by `PGN.init(parse:)`.
    public enum ParseError: Error {

        // MARK: Cases

        /// Unexpected quote found in move text.
        case unexpectedQuote(String)

        /// Unexpected closing brace found outside of comment.
        case unexpectedClosingBrace(String)

        /// No closing brace for comment.
        case noClosingBrace(String)

        /// No closing quote for tag value.
        case noClosingQuote(String)

        /// No closing bracket for tag pair.
        case noClosingBracket(String)
        
        /// Wrong number of tokens for tag pair.
        case tagPairTokenCount([String])
        
        /// Incorrect count of parenthesis for recursive annotation variation.
        case parenthesisCountForRAV(String)
        
        /// Invalid tag name.
        case invalidTagName(String)

    }

    // MARK: - Private Stored Properties

    /// The tag pairs for `self`.
    private var _tagPairs: [Tag: String]

    /// The moves in standard algebraic notation.
    private var _sanMoves: [String]

    // MARK: - Initializers

    /// Create PGN by parsing `string`.
    ///
    /// - throws: `ParseError` if an error occured while parsing.
    public init(parse string: String) throws {
        self.init()
        if string.isEmpty { return }
        for line in string.splitByNewlines() {
            if line.characters.first == "[" {
                let stripped = try line._commentsStripped(strings: true)
                let (tag, value) = try stripped._tagPair()
                self._tagPairs[tag] = value
            } else if line.characters.first != "%" {
                let stripped = try line._commentsStripped(strings: false)
                let (moves, outcome) = try stripped._moves()
                self._sanMoves += moves
                if let outcome = outcome {
                    self.outcome = outcome
                }
            }
        }
    }

    // Create PGN with `tagPairs` and `moves`.
    public init(tagPairs: [Tag: String] = [:], moves: [String] = []) {
        self._sanMoves = moves
        self._tagPairs = tagPairs
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

    // MARK: - Public Computed Properties and Functions

    /// The game outcome.
    public var outcome: Outcome {
        get {
            return self[Tag.result].flatMap(Outcome.init) ?? .undetermined
        }
        set {
            self[Tag.result] = newValue.description
        }
    }

    public var sanMoves: [String] {
        return _sanMoves
    }

    public var tagPairs: [Tag: String] {
        return _tagPairs
    }

    public var exportTagPairs: String {
        var result = ""
        var tagPairs = self._tagPairs
        for (tag, defaultValue) in Tag.roster {
            if let value = tagPairs[tag] {
                tagPairs[tag] = nil
                result += "[\(tag.rawValue) \"\(value)\"]\n"
            } else {
                result += "[\(tag.rawValue) \"\(defaultValue)\"]\n"
            }
        }
        for (tag, value) in tagPairs {
            result += "[\(tag.rawValue) \"\(value)\"]\n"
        }
        return result
    }

    public var fullMoves: [String] {
        var result = [String]()
        for num in stride(from: 0, to: _sanMoves.endIndex, by: 2) {
            let moveNumber = (num + 2) / 2
            var moveString = "\(moveNumber). \(_sanMoves[num])"
            if num + 1 < _sanMoves.endIndex {
                moveString += " \(_sanMoves[num+1])"
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
        for element in fullMoves + [self.outcome.description] {
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

    // MARK: - Subscripts

    /// Get or set the value for `tag`.
    public subscript(tag: Tag) -> String? {
        get {
            return _tagPairs[tag]
        }
        set {
            _tagPairs[tag] = newValue
        }
    }

    // MARK: - Equatable Protocol Conformance

    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: PGN, rhs: PGN) -> Bool {
        return lhs._tagPairs == rhs._tagPairs
            && lhs._sanMoves == rhs._sanMoves
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
        var ravDepth = 0
        var startIndex = self.startIndex
        let _lastIndex = lastIndex
        for (index, character) in zip(characters.indices, characters) {
            if character == "(" {
                if ravDepth == 0 {
                    stripped += self[startIndex ..< index]
                }
                ravDepth += 1
            } else if character == ")" {
                ravDepth -= 1
                if ravDepth == 0 {
                    startIndex = self.index(after: index)
                }
            } else if index == _lastIndex && ravDepth == 0 {
                stripped += self[startIndex ... index]
            }
        }
        guard ravDepth == 0 else {
            throw PGN.ParseError.parenthesisCountForRAV(self)
        }
        let tokens = stripped.split(by: [" ", "."])
        let outcomes = Outcome.all.map { $0.description }
        let moves = tokens.filter { $0.characters.first?.isDigit == false && !outcomes.contains($0) }
        let outcome = tokens.last.flatMap(Outcome.init)
        return (moves, outcome)
    }

    fileprivate func _commentsStripped(strings consideringStrings: Bool) throws -> String {

        var stripped = ""
        var _startIndex = startIndex
        let _lastIndex = lastIndex
        var afterEscape = false
        var inString = false
        var inComment = false

        for (index, character) in zip(characters.indices, characters) {
            if character == "\\" {
                afterEscape = true
                continue
            }
            if character == "\"" {
                if !inComment {
                    guard consideringStrings else {
                        throw PGN.ParseError.unexpectedQuote(self)
                    }
                    if !inString {
                        inString = true
                    } else if !afterEscape {
                        inString = false
                    }
                }
            } else if !inString {
                if character == ";" && !inComment {
                    stripped += self[_startIndex ..< index]
                    break
                } else if character == "{" && !inComment {
                    inComment = true
                    stripped += self[_startIndex ..< index]
                } else if character == "}" {
                    guard inComment else {
                        throw PGN.ParseError.unexpectedClosingBrace(self)
                    }
                    inComment = false
                    _startIndex = self.index(after: index)
                }
            }
            if index >= _startIndex && index == _lastIndex && !inComment {
                stripped += self[_startIndex ... index]
            }
            afterEscape = false
        }
        guard !inString else {
            throw PGN.ParseError.noClosingQuote(self)
        }
        guard !inComment else {
            throw PGN.ParseError.noClosingBrace(self)
        }
        return stripped
    }
    
}

