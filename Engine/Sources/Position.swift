//
//  Position.swift
//  Engine
//
//  Created by Todd Olsen on 9/19/16.
//
//

/// A game position.
public struct Position: Equatable, CustomStringConvertible {

    // MARK: Stored Properties

    /// The board for the position.
    public var board: Board

    /// The active player turn.
    public var playerTurn: PlayerTurn

    /// The castling rights.
    public var castlingRights: CastlingRights

    /// The en passant target location.
    public var enPassantTarget: Square?

    /// The halfmove number.
    public var halfmoves: UInt

    /// The fullmove clock.
    public var fullmoves: UInt

    // MARK: Initializers

    /// Create a position.
    public init(board: Board = Board(),
                playerTurn: PlayerTurn = .white,
                castlingRights: CastlingRights = .all,
                enPassantTarget: Square? = nil,
                halfmoves: UInt = 0,
                fullmoves: UInt = 1) {
        self.board = board
        self.playerTurn = playerTurn
        self.castlingRights = castlingRights
        self.enPassantTarget = enPassantTarget
        self.halfmoves = halfmoves
        self.fullmoves = fullmoves
    }

    /// Create a position from a valid FEN string.
    public init?(fen: String) {

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
            else { return nil }

        var ep: Square? = nil
        let epStr = parts[3]
        let epChars = epStr.characters
        if epChars.count == 2 {
            guard let candidate = Square(epStr) else { return nil }
            ep = candidate
        } else {
            guard epStr == "-" else {
                return nil
            }
        }
        self.init(board: board,
                  playerTurn: playerTurn,
                  castlingRights: rights,
                  enPassantTarget: ep,
                  halfmoves: halfmoves,
                  fullmoves: fullmoves)
    }

    // MARK: Computed Properties and Functions

    /// A textual representation of `self`.
    public var description: String {
        return fen()
    }

    /// Returns the FEN string for the position.
    public func fen() -> String {
        let transform = { "\($0 as Square)".lowercased() }
        return board.fen()
            + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights.description) "
            + (enPassantTarget.map(transform) ?? "-")
            + " \(halfmoves) \(fullmoves)"
    }

    // MARK: - Equatable Protocol Conformance

    /// Returns `true` iff the two positions are the same.
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.playerTurn == rhs.playerTurn
            && lhs.castlingRights == rhs.castlingRights
            && lhs.halfmoves == rhs.halfmoves
            && lhs.fullmoves == rhs.fullmoves
            && lhs.enPassantTarget == rhs.enPassantTarget
            && lhs.board == rhs.board
    }

}

