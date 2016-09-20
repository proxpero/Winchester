//
//  HistoryItem.swift
//  Engine
//
//  Created by Todd Olsen on 9/20/16.
//
//

// MARK: -

/// The type of the element stored in a `game`'s `moveHistory` property.
public struct HistoricalMove: Equatable {

    // MARK: Stored Properties

    let move: Move
    let piece: Piece
    let capture: Piece?
    let kingAttackers: Bitboard
    let halfmoves: UInt
    let rights: CastlingRights
    let disambiguation: String?
    let kingStatus: KingStatus

    // MARK: Public Functions

    mutating func setKingStatus(newStatus: KingStatus) {
        self = HistoricalMove(
            move: self.move,
            piece: self.piece,
            capture: self.capture,
            kingAttackers: self.kingAttackers,
            halfmoves: self.halfmoves,
            rights: self.rights,
            disambiguation: self.disambiguation,
            kingStatus: newStatus)
    }

    // MARK: - Equatable Protocol Conformance

    /// Returns `true` iff the two `HistoricalMove` instances are the same.
    public static func == (lhs: HistoricalMove, rhs: HistoricalMove) -> Bool {
        return lhs.move == rhs.move &&
            lhs.piece == rhs.piece &&
            lhs.capture == rhs.capture &&
            lhs.kingAttackers == rhs.kingAttackers &&
            lhs.halfmoves == rhs.halfmoves &&
            lhs.rights == rhs.rights &&
            lhs.disambiguation == rhs.disambiguation &&
            lhs.kingStatus == rhs.kingStatus
    }

}

// MARK: -

/// The states a king could be in during a game.
public enum KingStatus {
    case safe
    case checked
    case checkmated
}

// MARK: - Execution Error Type

/// An error in move execution.
///
/// Thrown by the `execute(move:promotion:)` or `execute(uncheckedMove:promotion:)` method for a `Game` instance.
public enum ExecutionError: Error {

    // MARK: Cases

    /// Missing piece at a square.
    case missingPiece(Square)

    /// Attempted illegal move.
    case illegalMove(Move, Color, Board)

    /// Could not promote with a piece kind.
    case invalidPromotion(Piece.Kind)

    // MARK: Computed Properties and Functions

    /// The error message
    public var message: String {
        switch self {
        case let .missingPiece(square):
            return "Missing piece: \(square)"
        case let .illegalMove(move, color, board):
            return "Illegal move: \(move) for \(color) on \(board)"
        case let .invalidPromotion(pieceKind):
            return "Invalid promoton: \(pieceKind)"
        }
    }

}
