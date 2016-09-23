//
//  Position.swift
//  Engine
//
//  Created by Todd Olsen on 9/19/16.
//
//

import Foundation

/// A game position.
public struct Position: Equatable, CustomStringConvertible {

    // MARK: - Stored Properties

    /// The board for the position.
    internal private(set) var board: Board

    /// The active player turn.
    internal private(set) var playerTurn: PlayerTurn

    /// The castling rights.
    internal private(set) var castlingRights: CastlingRights

    /// The en passant target location.
    internal private(set) var enPassantTarget: Square?

    /// The halfmove number.
    internal private(set) var halfmoves: UInt

    /// The fullmove clock.
    internal private(set) var fullmoves: UInt

    ///
    internal private(set) var _attackersToKing: Bitboard = 0

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

    public func move(forSan input: String) -> (Move, Piece?)? {

        if input == "O-O" { return (Move(castle: playerTurn, side: .kingside), nil) }
        if input == "O-O-O" { return (Move(castle: playerTurn, side: .queenside), nil) }

        var promotion: Piece? = nil

        if
            input.characters.count > 2,
            input.substring(from: input.index(before: input.lastIndex)).hasPrefix("="),
            let char = input.characters.last,
            let piece = Piece(character: char),
            piece.kind == .pawn
        {
            promotion = piece
        }

        let san = input.trimmingCharacters(in: CharacterSet(charactersIn: "+=!?#"))


        let index = san.index(san.endIndex, offsetBy: -2)
        guard let target = Square(san.substring(from: index)) else {
            return nil
        }

        var candidate = san.substring(to: index)

        if
            candidate.isEmpty,
            let start = origin(for: Piece(pawn: playerTurn), target: target, candidates: target.file.bitmask)
        {
            return (Move(origin: start, target: target), promotion)
        }

        candidate = candidate.trimmingCharacters(in: CharacterSet(charactersIn: "x"))

        if candidate.characters.count == 1, let char = candidate.characters.first {

            // Regular move
            if let kind = Piece.Kind(character: char) {
                let piece = Piece(kind: kind, color: playerTurn)
                if let start = origin(for: piece, target: target, candidates: board.bitboard(for: piece)) {
                    return (Move(origin: start, target: target), promotion)
                }
            }

            // Pawn capture
            if
                let file = File(char), let start = origin(for: Piece(pawn: playerTurn), target: target, candidates: file.bitmask) {
                return (Move(origin: start, target: target), promotion)
            }

        }

        if
            candidate.characters.count == 2,
            let char = candidate.characters.first,
            let kind = Piece.Kind(character: char)
        {
            let disambiguation = candidate.characters[candidate.index(after: candidate.startIndex)]

            if
                let file = File(disambiguation),
                let start = origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: file.bitmask)
            {
                return (Move(start, target), promotion)
            }

            if
                let num = Int(String(disambiguation)),
                let rank = Rank(num),
                let start = origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: rank.bitmask)
            {
                return (Move(start, target), promotion)
            }
        }
        return nil
    }

    /// Returns the square a piece must have originated from to have arrived at
    /// the target square. This is useful when reconstructing a game from a list
    /// of moves.
    ///
    /// - parameter piece: the `Piece` that made the move.
    /// - parameter target: the `Square` that `piece` moved to.
    /// - parameter candidates: a bitboard holding a set of the possible squares
    ///   the piece might have originated from. This function uses the bitboard
    ///   to disambiguate possible origins. This function already filters for
    ///   pieces. The caller should filter for files or ranks, for example, to
    ///   help disambiguate.
    public func origin(for piece: Piece, target: Square, candidates: Bitboard = Bitboard.full) -> Square? {
        return (board.bitboard(for: piece) & candidates).filter { _canExecute(move: Move(origin: $0, target: target)) }.first
    }

    /// Returns the FEN string for the position.
    public var fen: String {
        return board.fen
            + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights.description) "
            + (enPassantTarget?.description ?? "-")
            + " \(halfmoves) \(fullmoves)"
    }

    // MARK: - Internal Computed Properties and Functions

    private var _outcome: Outcome {
        let inCheck = board.isKingInCheck(for: playerTurn)
        let canMove = _legalTargetsBitboard(for: playerTurn, considerHalfmoves: true).count > 0

        switch (inCheck, canMove) {
        case (true, false): return .win(playerTurn.inverse())
        case (false, false): return .draw
        default: return .undetermined
        }
    }

    internal var _kingStatus: KingStatus {
        let inCheck = board.isKingInCheck(for: playerTurn)
        let canMove = _legalTargetsBitboard(for: playerTurn, considerHalfmoves: true).count > 0
        switch (inCheck, canMove) {
        case (true, false): return .checkmated
        case (true, true): return .checked
        default: return .safe
        }
    }

    // MARK: - Legal Moves

    /// Returns `true` if the move is legal.
    internal func _canExecute(move: Move) -> Bool {
        return move.target.bitmask.intersects(_legalTargetSquares(from: move.origin, considerHalfmoves: true).bitmask)
    }

    internal func _legalTargetSquares(considerHalfmoves: Bool) -> [Square] {
        return _legalTargetSquares(for: playerTurn, considerHalfmoves: considerHalfmoves)
    }

    internal func _legalTargetsBitboard(for color: Color, considerHalfmoves: Bool) -> Bitboard {
        return board.bitboard(for: color).reduce(0) { $0 | _legalTargetSquares(from: $1, considerHalfmoves: considerHalfmoves).bitmask }
    }

    internal func _legalTargetSquares(for color: Color, considerHalfmoves: Bool = false) -> [Square] {
        return _legalTargetsBitboard(for: color, considerHalfmoves: considerHalfmoves).map { $0 }
    }

    internal var _uncheckedGuardingMoves: [Move] {
        return board._uncheckedGuardingMoves(for: playerTurn)
    }

    /// An array of `Square`s currently occupied by `color` and which can
    /// be retaken in the event that one is captured. 
    ///
    /// - parameter color: The color whose position is under consideration.
    ///
    /// - returns: An array of `Square`s which can be seized by `color`
    /// - warning: The resulting `Square`s are not necessarily unique.
    internal var _uncheckedGuardedSquares: [Square] {
        return _uncheckedGuardingMoves.map { $0.target }
    }

    internal func _undefendedSquares(for color: Color) -> [Square] {
        return []
    }

    internal func _legalCaptures(for color: Color) -> [Square] {
        let moves = board.bitboard(for: color)
            .reduce(0) { $0 | _legalTargetSquares(from: $1).bitmask }
        let opponents = board.bitboard(for: color.inverse())
        return (moves & opponents).map { $0 }
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    internal func _legalTargetSquares(from origin: Square, considerHalfmoves: Bool = false) -> [Square] {

        if considerHalfmoves && halfmoves >= 100 {
            return []
        }

        // No piece -> no bitboard.
        guard
            let piece = board[origin],
            piece.color == playerTurn
        else { return [] }

        // Only the king can move if he is double checked.
        if isKingInMultipleCheck {
            guard piece.kind.isKing else {
                return []
            }
        }

        let playerBits = board.bitboard(for: playerTurn)
        let enemyBits = board.bitboard(for: playerTurn.inverse())
        let occupiedBits = playerBits | enemyBits
        let emptyBits = ~occupiedBits
        let squareBit = origin.bitmask

        var movesBitboard: Bitboard = 0
        let attacks = origin.attacks(for: piece, obstacles: occupiedBits)

        if piece.kind.isPawn {
            let enPassant = enPassantTarget.map { $0.bitmask } ?? 0
            let pushes = squareBit._pawnPushes(for: playerTurn, empty: emptyBits)
            let doublePushes = (squareBit & piece.startingPositions)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
            movesBitboard |= pushes | doublePushes
                | (attacks & enemyBits)
                | (attacks & enPassant)
        } else {
            movesBitboard |= attacks & ~playerBits
        }

        if piece.kind.isKing && squareBit == piece.startingPositions {
            for right in castlingRights {
                // FIXME: Also take care that empty spaces are not attacked.
                if right.color == playerTurn && occupiedBits & right.emptySquares == 0 {
                    movesBitboard |= right.castleSquare.bitmask
                }
            }
        }

        func isLegal(target: Square) -> Bool {
            let move = Move(origin: origin, target: target)
            let isEnPassant = (enPassantTarget != nil) && (enPassantTarget! == target)
            let newBoard = board._execute(move: move, isEnPassant: isEnPassant)
            return newBoard.attackersToKing(for: playerTurn).count == 0
        }

        return movesBitboard.filter(isLegal)
    }

    internal func _execute(uncheckedMove move: Move, promotion: Piece? = nil) -> HistoryItem? {

        guard let piece = board[move.origin] else {
            return nil
        }

        var newBoard = board
        var endPiece = piece
        var captureSquare = move.target
        var capture = board[captureSquare]
        var rights = castlingRights

        if piece.kind.isPawn {
            if move.target.rank == Rank(endFor: playerTurn) {
                guard
                    let promo = promotion,
                    promo.kind.isPromotionType() else {
                        fatalError("Unexpected Promotion: \(promotion)")
                }
                endPiece = Piece(kind: promo.kind, color: playerTurn)
            } else if move.target == enPassantTarget {
                capture = Piece(pawn: playerTurn.inverse())
                captureSquare = Square(file: move.target.file, rank: move.origin.rank)
            }
        } else if piece.kind.isRook {
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
            if move.isCastle(for: playerTurn) {
                let (old, new) = move._castleSquares()
                let rook = Piece(rook: playerTurn)
                newBoard[rook][old] = false
                newBoard[rook][new] = true
            }
        }

        newBoard[piece][move.origin] = false
        newBoard[endPiece][move.target] = true
        if let capture = capture {
            newBoard[capture][captureSquare] = false
        }

        guard newBoard.attackersToKing(for: playerTurn).count == 0 else {
            return nil
        }

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
                        .map { $0.bitmask }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    let sameRank = Rank.all
                        .map { $0.bitmask }
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

            if isCapture{
                result.append("x")
            }

            result += move.target.description
            result += newPosition._kingStatus.algebraicAnnotation
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
            sanMove: sanMove(with: newPosition)
        )
    }

    func _execute(sanMove: String) -> HistoryItem? {
        guard let (move, promotion) = move(forSan: sanMove) else { return nil }
        return _execute(uncheckedMove: move, promotion: promotion)
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

