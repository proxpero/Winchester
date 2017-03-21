//
//  Position.swift
//  Endgame
//
//  Created by Todd Olsen on 9/19/16.
//
//

import Foundation

/// A game position.
public struct Position: Equatable, CustomStringConvertible {

    // MARK: - Stored Properties

    /// The board for the position.
    public let board: Board

    /// The active player turn.
    internal let playerTurn: PlayerTurn

    /// The castling rights.
    internal let castlingRights: CastlingRights

    /// The en passant target location.
    internal let enPassantTarget: Square?

    /// The halfmove number.
    internal let halfmoves: UInt

    /// The fullmove clock.
    internal let fullmoves: UInt

    /// Returns `true` if the current player's king is in check.
    internal let isKingInCheck: Bool

    /// Returns `true` if the current player's king is checked by two or more pieces.
    internal let isKingInMultipleCheck: Bool

    /// Attackers to king
    internal let attackersToKing: Bitboard

    /// The outcome of the game.
    internal private(set) var outcome: Outcome?

    /// The `KingStatus` for this position.
    internal private(set) var kingStatus: KingStatus = .safe

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

        let attackersToKing = board.attackersToKing(for: playerTurn)
        self.attackersToKing = attackersToKing
        self.isKingInMultipleCheck = attackersToKing.count > 1
        self.isKingInCheck = attackersToKing.count != 0

        let legalTargets = _legalTargetsBitboard(for: playerTurn, considerHalfmoves: true)


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

    // MARK: - Public Computed Properties and Functions

    /// Returns `true` if the `move` is a promotion.
    public func isPromotion(for move: Move) -> Bool {
        guard move.target.rank == Rank(endFor: playerTurn), let piece = board[move.origin], piece.kind == .pawn else { return false }
        return true
    }

    /// Returns the FEN string for the position.
    public var fen: String {
        return board.fen
            + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights.description) "
            + (enPassantTarget?.description ?? "-")
            + " \(halfmoves) \(fullmoves)"
    }

    /// An ascii representation of the board.
    public var ascii: String {
        return board.ascii
    }


    // MARK: - Legal Moves

//    /// Returns `true` if the move is legal.
//    func canExecute(move: Move) -> Bool {
//        return move.target.bitboard.intersects(_legalTargetSquares(from: move.origin, considerHalfmoves: true).bitboard)
//    }
//
//    internal func _legalTargetSquares(considerHalfmoves: Bool) -> [Square] {
//        return _legalTargetSquares(for: playerTurn, considerHalfmoves: considerHalfmoves)
//    }
//
//    internal func _legalTargetsBitboard(for color: Color, considerHalfmoves: Bool) -> Bitboard {
//        return board.bitboard(for: color).reduce(0) { $0 | _legalTargetSquares(from: $1, considerHalfmoves: considerHalfmoves).bitboard }
//    }
//
//    internal func _legalTargetSquares(for color: Color, considerHalfmoves: Bool = false) -> [Square] {
//        return _legalTargetsBitboard(for: color, considerHalfmoves: considerHalfmoves).map { $0 }
//    }
//
//    internal func _attackedOccupations(for color: Color) -> [Square] {
//        return board.attackedOccupations(for: color).map { $0 }
//    }
//
//    internal func pieceDefenses() -> [Color: [Square: Bitboard]] {
//        /// TODO
//        return [:]
////        return board._pieceDefenses()
//    }
//
//    internal func _defendedOccupations(for color: Color) -> [Square] {
//        return []
////        return _pieceDefenses[color]!.filter { !$0.value.isEmpty }.map { $0.key }
//    }
//
//    internal func _undefendedOccupations(for color: Color) -> [Square] {
//        return []
////        return _pieceDefenses[color]!.filter { $0.value.isEmpty }.map { $0.key }
//    }
//
//    internal func _threatenedEnemies(for color: Color) -> [Square] {
//        return board.threatenedEnemies(for: color).map { $0 }
//    }
//
//    internal func _attackers(targeting square: Square, for color: Color) -> [Square] {
//        return board.attackers(targeting: square, color: color).map { $0 }
//    }
//
//    func _legalCaptures(for color: Color) -> [Square] {
//        let moves = board.bitboard(for: color)
//            .reduce(0) { $0 | _legalTargetSquares(from: $1).bitboard }
//        let opponents = board.bitboard(for: color.inverse())
//        return (moves & opponents).map { $0 }
//    }
//
//    internal func _legalCaptures(forPieceAt origin: Square) -> [Square] {
//        let targets = _legalTargetSquares(from: origin).bitboard
//        let opponents = board.bitboard(for: playerTurn.inverse())
//        return (targets & opponents).map { $0 }
//    }
//
//    func legalTargets(from origin: Square, considerHalfmoves: Bool = false) -> [Square] {
//        return []
//    }
//
//    /// Returns the moves bitboard currently available for the piece at `square`, if any.
//    internal func _legalTargetSquares(from origin: Square, considerHalfmoves: Bool = false) -> [Square] {
//
//        if considerHalfmoves && halfmoves >= 100 {
//            return []
//        }
//
//        // No piece => no bitboard.
//        guard
//            let piece = board[origin],
//            piece.color == playerTurn
//        else { return [] }
//
//        // Only the king can move if he is double checked.
//        if isKingInMultipleCheck {
//            guard piece.kind.isKing else {
//                return []
//            }
//        }
//
//        let playerBits = board.bitboard(for: playerTurn)
//        let enemyBits = board.bitboard(for: playerTurn.inverse())
//        let occupiedBits = playerBits | enemyBits
//        let emptyBits = ~occupiedBits
//        let squareBit = origin.bitboard
//
//        var movesBitboard: Bitboard = 0
//
//        let attacks = squareBit.attacks(for: piece, obstacles: occupiedBits)
//
//        if piece.kind.isPawn {
//            let enPassant = enPassantTarget.map { $0.bitboard } ?? 0
//            let pushes = squareBit._pawnPushes(for: playerTurn, empty: emptyBits)
//            let doublePushes = (squareBit & piece.startingPositions)
//                ._pawnPushes(for: playerTurn, empty: emptyBits)
//                ._pawnPushes(for: playerTurn, empty: emptyBits)
//            movesBitboard |= pushes | doublePushes | (attacks & enemyBits) | (attacks & enPassant)
//        } else {
//            movesBitboard |= attacks & ~playerBits
//        }
//
//        if piece.kind.isKing && squareBit == piece.startingPositions && !isKingInCheck {
//            for right in castlingRights {
//                if right.color == playerTurn
//                    && occupiedBits & right.emptySquares == 0
//                    && (board.attacks(for: playerTurn.inverse()) & right.emptySquares) == 0
//                {
//                    movesBitboard |= right.castleSquare.bitboard
//                }
//            }
//        }
//
//        func isLegal(target: Square) -> Bool {
//            let move = Move(origin: origin, target: target)
//            let isEnPassant = (enPassantTarget != nil) && (enPassantTarget! == target)
//            guard let (newBoard, _) = board._execute(uncheckedMove: move, for: playerTurn, isEnPassant: isEnPassant, promotion: Piece(queen: playerTurn)) else { return false }
//            return newBoard.attackersToKing(for: playerTurn).count == 0
//        }
//
//        return movesBitboard.filter(isLegal)
//    }

    internal func execute(uncheckedMove move: Move, promotion: Piece? = nil) -> HistoryItem? {

        guard let piece = board[move.origin] else {
            return nil
        }

        var rights = castlingRights

        if piece.kind.isRook {
            switch move.origin {
            case .a1: rights.remove(.whiteQueenside)
            case .h1: rights.remove(.whiteKingside)
            case .a8: rights.remove(.blackQueenside)
            case .h8: rights.remove(.blackKingside)
            default:
                break
            }
        } else if piece.kind.isKing {
            for option in castlingRights where option.color == playerTurn {
                rights.remove(option)
            }
        }

        guard let (newBoard, capture) = board.execute(uncheckedMove: move, for: playerTurn, isEnPassant: move.target == enPassantTarget, promotion: promotion) else { return nil }

        let enPassant: Square? = {
            guard
                let piece = board[move.origin],
                piece.kind.isPawn,
                abs(move.rankChange) == 2
                else { return nil }
            return Square(file: move.origin.file, rank: move.isUpward ? 3 : 6)
        }()

        /// Returns the Standard Algebraic Notation string representation of the
        /// move executed to create the new position.
        func sanMove(with newPosition: Position) -> String {

            if move.isCastle(for: playerTurn) {
                return move.isRightward ? "O-O" : "O-O-O"
            }

            var result = ""

            func disambiguation() -> String? {
                let attacks = board.attacks(by: piece, to: move.target)
                if piece.kind != .pawn && piece.kind != .king && attacks.count > 1 {
                    let sameFile = File.all
                        .map { $0.bitboard }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    let sameRank = Rank.all
                        .map { $0.bitboard }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    switch (sameFile, sameRank) {
                    case (true, false): return move.origin.rank.description
                    case (false, _): return String(move.origin.file.character)
                    default: return String(move.origin.file.character) + move.origin.rank.description
                    }
                }
                return nil
            }

            let isCapture = capture != nil

            if let c = piece.kind.character {
                result.append(c)
                if let disambiguation = disambiguation() {
                    result += disambiguation
                }
            } else if isCapture {
                result.append(move.origin.file.character)
            }

            if isCapture {
                result.append("x")
            }

            result += move.target.description
            result += newPosition.kingStatus.algebraicAnnotation

            if let promotion = promotion, let char = promotion.kind.character {
                result += "=\(char)"
            }

            return result
        }

        let newHalfmoves: UInt = {
            if capture == nil && !piece.kind.isPawn {
                return halfmoves + 1
            } else {
                return 0
            }
        }()

        let newPosition = Position(
            board: newBoard,
            playerTurn: playerTurn.inverse(),
            castlingRights: rights,
            enPassantTarget: enPassant,
            halfmoves: newHalfmoves,
            fullmoves: playerTurn.isBlack ? fullmoves + 1 : fullmoves
        )
        
        return HistoryItem(
            position: newPosition,
            move: move,
            piece: piece,
            capture: capture,
            promotion: promotion,
            sanMove: sanMove(with: newPosition)
        )
    }

    func execute(sanMove: String) throws -> HistoryItem? {
        let (move, promotion) = try self.move(for: sanMove)
        return execute(uncheckedMove: move, promotion: promotion)
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

