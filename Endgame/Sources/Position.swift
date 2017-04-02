//
//  Position.swift
//  Endgame
//
//  Created by Todd Olsen on 9/19/16.
//
//

import Foundation

/// A game position.
public struct Position {

    /// The board for the position.
    public let board: Board

    /// The active player turn.
    let playerTurn: PlayerTurn

    /// The castling rights.
    let castlingRights: Castle

    /// The en passant target square.
    let enPassantTarget: Square?

    /// The halfmove clock.
    let halfmoves: UInt

    /// The fullmove counter.
    let fullmoves: UInt

    /// Returns `true` if the current player's king is in check.
    /// Computed at initialization.
    let isKingInCheck: Bool

    /// Returns `true` if the current player's king is checked by two or more pieces.
    /// Computed at initialization.
    let isKingInMultipleCheck: Bool

    /// Attackers to king
    /// Computed at initialization.
    let attackersToKing: Bitboard

    /// The outcome of the game.
    /// Computed at initialization.
    private(set) var outcome: Outcome?

    /// The `KingStatus` for this position.
    /// Computed at initialization.
    private(set) var kingStatus: Position.KingStatus = .safe

    /// Designated struct initializer. Any creation of a `Position` must pass
    /// through this initializer. Defaults to a standard position board setup
    /// with white to move first.
    public init(board: Board = Board(),
                playerTurn: PlayerTurn = .white,
                castlingRights: Castle = .all,
                enPassantTarget: Square? = nil,
                halfmoves: UInt = 0,
                fullmoves: UInt = 1) {
        self.board = board
        self.playerTurn = playerTurn
        self.castlingRights = castlingRights
        self.enPassantTarget = enPassantTarget
        self.halfmoves = halfmoves
        self.fullmoves = fullmoves

        let attackersToKing = board.attackersToKing(for: playerTurn)
        self.attackersToKing = attackersToKing
        self.isKingInMultipleCheck = attackersToKing.count > 1
        self.isKingInCheck = attackersToKing.count != 0

        let legalTargets = legalTargetsBitboard(for: playerTurn, considerHalfmoves: true)

        self.outcome = {
            let canMove = legalTargets.count > 0
            switch (isKingInCheck, canMove) {
            case (true, false): return .win(playerTurn.inverse())
            case (false, false): return .draw
            default: return nil
            }
        }()

        self.kingStatus = {
            let inCheck = board.isKingInCheck(for: playerTurn)
            let canMove = legalTargets.count > 0
            switch (inCheck, canMove) {
            case (true, false): return .checkmated
            case (true, true): return .checked
            default: return .safe
            }
        }()
    }

}

extension Position {

    /// Returns `true` if the `move` is a promotion for the player whose turn it is.
    public func isPromotion(for move: Move) -> Bool {
        guard move.target.rank == Rank.ending(for: playerTurn), let piece = board[move.origin], piece.kind == .pawn else { return false }
        return true
    }

    /// Returns the FEN string for the position.
    /// See https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation
    public var fen: String {
        return "\(board.fen) \(playerTurn.isWhite ? "w" : "b") \(castlingRights.description) \(enPassantTarget?.description ?? "-") \(halfmoves) \(fullmoves)"
    }

    /// An graphical representation of the board using ascii characters.
    public var ascii: String {
        return board.ascii
    }

}

extension Position: Equatable {

    /// Equatable conformance.
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.playerTurn == rhs.playerTurn &&
            lhs.castlingRights == rhs.castlingRights &&
            lhs.halfmoves == rhs.halfmoves &&
            lhs.fullmoves == rhs.fullmoves &&
            lhs.enPassantTarget == rhs.enPassantTarget &&
            lhs.board == rhs.board
    }

}

extension Position: CustomStringConvertible {

    /// CustomStringConvertible conformance

    public var description: String {
        return fen
    }

}
