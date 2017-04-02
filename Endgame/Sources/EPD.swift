//
//  EPD.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

import Foundation

/// A representation of Extended Position Description data.
public struct EPD {

    /// The position for `self`.
    public var position: Position

    /// The opcodes for `self`.
    public var opcodes: [Opcode]

    /// Create an EPD.
    ///
    /// - parameter position: the initial position of the pieces in the EPD.
    /// - parameter opcodes:
    public init(position: Position, opcodes: [Opcode]) {
        self.position = position
        self.opcodes = opcodes
    }

    /// Creates an `EPD` from a string.
    public init(parse epd: String) throws {
        let components = epd.split(by: Character.whitespaces)
        let fen = (0...3).map { components[$0] }.joined(separator: " ") + " 0 1"
        let position = try Position(fen: fen)
        var opcodes: [EPD.Opcode] = []

        let codes = (4..<components.endIndex).map { components[$0] }.joined(separator: " ").splitBySemicolon()

        for entry in codes.map({ $0.splitByWhitespaces() }) {
            guard let op = entry.first else {
                throw ParseError.invalidCode(epd)
            }
            let rest = entry.dropFirst().map { $0.trimmingCharacters(in: .punctuationCharacters) }
            guard !rest.isEmpty else { fatalError() }
            if let opcode = EPD.Opcode(tag: op, value: rest) {
                opcodes.append(opcode)
            }
        }
        self.init(position: position, opcodes: opcodes)
    }
}

extension EPD: Equatable {
    public static func == (lhs: EPD, rhs: EPD) -> Bool {
        return lhs.position == rhs.position && lhs.opcodes == rhs.opcodes
    }
}
