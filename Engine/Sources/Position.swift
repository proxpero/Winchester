//
//  Position.swift
//  Engine
//
//  Created by Todd Olsen on 9/19/16.
//
//

/// A game position.
public struct Position: Equatable, CustomStringConvertible {

    // MARK: - Stored Properties

    /// The board for the position.
    public private(set) var board: Board

    /// The active player turn.
    public private(set) var playerTurn: PlayerTurn

    /// The castling rights.
    public private(set) var castlingRights: CastlingRights

    /// The en passant target location.
    public private(set) var enPassantTarget: Square?

    /// The halfmove number.
    public private(set) var halfmoves: UInt

    /// The fullmove clock.
    public private(set) var fullmoves: UInt


    public private(set) var _attackersToKing: Bitboard = 0

    /// The outcome of the position.
    public private(set) var outcome: Outcome?

    // MARK: - Public Initializers

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
        self._attackersToKing = board.attackersToKing(for: playerTurn)
        self.outcome = _outcome
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
        self.outcome = _outcome
        self._attackersToKing = board.attackersToKing(for: playerTurn)
    }

    // MARK: - Public Computed Properties and Functions

    /// Returns `true` if the current player's king is in check.
    public var isKingInCheck: Bool {
        return board.isKingInCheck(for: playerTurn)
    }

    /// Returns `true` if the current player's king is checked by two or more pieces.
    public var isKingInMultipleCheck: Bool {
        return board.isKingInMultipleCheck(for: playerTurn)
    }

    /// Returns the FEN string for the position.
    public var fen: String {
        let transform = { "\($0 as Square)".lowercased() }
        return board.fen()
            + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights.description) "
            + (enPassantTarget.map(transform) ?? "-")
            + " \(halfmoves) \(fullmoves)"
    }

    // MARK: - Private Computed Properties and Functions

    private var _outcome: Outcome? {
        let inCheck = board.isKingInCheck(for: playerTurn)
        let canMove = _legalTargets(considerHalfmoves: true).count == 0

        switch (canMove, inCheck) {
        case (false, true): return Outcome.win(playerTurn.inverse())
        case (false, false): return Outcome.draw
        default:
            return nil
        }
    }

    internal var _kingStatus: KingStatus {
        let checked = board.isKingInCheck(for: playerTurn)
        let mated = _legalTargets(considerHalfmoves: true).count == 0
        switch (checked, mated) {
        case (true, true): return .checkmated
        case (true, false): return .checked
        default: return .safe
        }
    }

    // MARK: - CustomStringConvertible Protocol Conformance

    public var description: String {
        return fen
    }

    // MARK: - Equatable Protocol Conformance

    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.playerTurn == rhs.playerTurn &&
                lhs.castlingRights == rhs.castlingRights &&
                lhs.halfmoves == rhs.halfmoves &&
                lhs.fullmoves == rhs.fullmoves &&
                lhs.enPassantTarget == rhs.enPassantTarget &&
                lhs.board == rhs.board
    }

}

