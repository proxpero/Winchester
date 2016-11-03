//
//  PGN+Error.swift
//  Endgame
//
//  Created by Todd Olsen on 11/2/16.
//
//

import Foundation

extension PGN {

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

}
