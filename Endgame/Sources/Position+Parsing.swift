//
//  Position+Parsing.swift
//  Endgame
//
//  Created by Todd Olsen on 3/20/17.
//
//

import Foundation // Used for CharacterSet

extension Position {

    /// Create a position from a valid FEN string.
    public init(fen: String) throws {

        let parts = fen.characters.split(separator: " ").map(String.init)

        // confirm a valid FEN was received.
        guard
            parts.count == 6,
            let board = Board(fen: parts[0]),
            parts[1].characters.count == 1,
            let playerTurn = parts[1].characters.first.flatMap(Color.init),
            let rights = CastlingRights(string: parts[2]),
            let halfmoves = UInt(parts[4]),
            let fullmoves = UInt(parts[5]),
            fullmoves > 0
            else {
                throw ParseError.invalidFEN(fen)
            }

        var ep: Square? = nil
        let epStr = parts[3]
        let epChars = epStr.characters
        if epChars.count == 2 {
            guard let candidate = Square(epStr) else {
                throw ParseError.invalidFEN(fen)
            }
            ep = candidate
        } else {
            guard epStr == "-" else {
                throw ParseError.invalidFEN(fen)
            }
        }
        self.init(board: board,
                  playerTurn: playerTurn,
                  castlingRights: rights,
                  enPassantTarget: ep,
                  halfmoves: halfmoves,
                  fullmoves: fullmoves
        )
    }

    /// Generate the `Move` corresponding to the input `san` that is appropriate
    /// for the position `self`.
    ///
    /// Returns: a tuple comprising the move and an optional `Piece` representing
    /// a promotion piece or `nil` if there is no promotion. If a move cannot be
    /// generated with this input, the function returns `nil`.
    public func move(for sanMove: String) throws -> (Move, Piece?) {

        if sanMove == "O-O" {
            return (Move(castle: playerTurn, side: .kingside), nil)
        }

        if sanMove == "O-O-O" {
            return (Move(castle: playerTurn, side: .queenside), nil)
        }

        let promotion: Piece? = {
            guard let eqIdx = sanMove.characters.index(of: "="), eqIdx != sanMove.lastIndex else { return nil }
            let char = sanMove[sanMove.index(after: eqIdx)]
            guard let kind = Piece.Kind(character: char), kind.isPromotionType else { return nil }
            return Piece(kind: kind, color: playerTurn)
        }()

        let san = sanMove.trimmingCharacters(in: CharacterSet(charactersIn: "=!?+#"))

        let index = san.index(san.endIndex, offsetBy: -2)

        // The target square of the represented move.
        guard let target = Square(san.substring(from: index)) else {
            throw ParseError.invalidMove(sanMove)
        }

        // String representing the moving piece.
        let candidate = san.substring(to: index).trimmingCharacters(in: CharacterSet(charactersIn: "x"))

        func origin(for piece: Piece, target: Square, candidates: Bitboard = Bitboard.full) throws -> Square {
            guard let result = (board.bitboard(for: piece) & candidates).filter({ canExecute(move: Move(origin: $0, target: target)) }).first else {
                throw ParseError.invalidMove(sanMove)
            }
            return result
        }

        // An ordinary pawn push.
        if candidate.isEmpty {
            let start = try origin(for: Piece(pawn: playerTurn), target: target, candidates: target.file.bitboard)
            return (Move(origin: start, target: target), promotion)
        }

        if candidate.characters.count == 1, let char = candidate.characters.first {

            // Regular move, `char` gives the `Piece.Kind`
            if let kind = Piece.Kind(character: char) {
                let piece = Piece(kind: kind, color: playerTurn)
                let start = try origin(for: piece, target: target, candidates: board.bitboard(for: piece))
                return (Move(origin: start, target: target), promotion)
            }

            // Pawn capture, `char` gives the originating `File`.
            if let file = File(char) {
                let start = try origin(for: Piece(pawn: playerTurn), target: target, candidates: file.bitboard)
                return (Move(origin: start, target: target), promotion)
            }

        }

        // At this point there is ambiguity as to which of multiple identical piece
        // kinds is moving to the target.
        if
            candidate.characters.count == 2,
            let char = candidate.characters.first,
            let kind = Piece.Kind(character: char)
        {
            // This character represents either the row or the file of the moving piece.
            let disambiguation = candidate.characters[candidate.index(after: candidate.startIndex)]

            if let file = File(disambiguation) {
                let start = try origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: file.bitboard)
                return (Move(start, target), promotion)
            }

            if let num = Int(String(disambiguation)), let rank = Rank(num) {
                let start = try origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: rank.bitboard)
                return (Move(start, target), promotion)
            }
        }

        throw ParseError.invalidMove(sanMove)
    }

}
