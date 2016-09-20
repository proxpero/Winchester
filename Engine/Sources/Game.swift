//
//  Game.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

import Foundation

/// A player turn.
public typealias PlayerTurn = Color

/// A chess game.
public class Game {

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
        public static func == (lhs: Game.HistoricalMove, rhs: Game.HistoricalMove) -> Bool {
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

    // MARK: - Public Stored Properties

    /// The game's delegate.
    public var delegate: GameDelegate?

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

    /// The game's variant.
    public let variant: Variant

    /// The game's board.
    public private(set) var board: Board

    /// The outcome of the game.
    public private(set) var outcome: Outcome?

    /// The current player's turn.
    public private(set) var playerTurn: PlayerTurn

    /// The castling rights.
    public private(set) var castlingRights: CastlingRights

    /// The current halfmove clock.
    public private(set) var halfmoves: UInt

    // MARK: - Private Stored Properties

    /// All of the conducted moves in the game.
    private var _moveHistory: Array<HistoricalMove>

    /// Attackers to the current player's king. This property is computed 
    /// and updated after every turn.
    private var _attackersToKing: Bitboard

    /// All of the undone moves in the game.
    private var _undoHistory: [(move: Move, promotion: Piece.Kind?, kingAttackers: Bitboard)]

    // MARK: - Public Initializers

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter variant: The game's chess variant. Default is standard.
    public init(whitePlayer: Player = Player(), blackPlayer: Player = Player(), variant: Variant = .standard) {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.variant = variant
        self.board = Board(variant: variant)
        self.playerTurn = .white
        self.castlingRights = .all
        self.halfmoves = 0
        self._moveHistory = []
        self._attackersToKing = 0x0
        self._undoHistory = []
    }



    // MARK: - Private Initializers

    /// Create a game from another.
    private init(game: Game) {
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self.variant = game.variant
        self.board = game.board
        self.outcome = game.outcome
        self.playerTurn = game.playerTurn
        self.castlingRights = game.castlingRights
        self.halfmoves = game.halfmoves
        self._moveHistory = game._moveHistory
        self._attackersToKing = game._attackersToKing
        self._undoHistory = game._undoHistory
    }

    // MARK: - Public Computed Properties

    public var moveHistory: Array<HistoricalMove> {
        return _moveHistory
    }

    /// The number of executed moves.
    public var moveCount: Int {
        return _moveHistory.count
    }

    /// All of the moves played in the game.
    public var playedMoves: [Move] {
        return _moveHistory.map({ $0.move })
    }

    /// The target square of an en passant.
    public var enPassantTarget: Square? {
        guard
            let historicalMove = _moveHistory.last,
            historicalMove.piece.kind.isPawn,
            abs(historicalMove.move.rankChange) == 2
        else { return nil }

        return Square(file: historicalMove.move.origin.file, rank: historicalMove.move.isUpward ? 3 : 6)
    }

    /// Algebraic representation of the half-move at `index`, where index 0 is
    /// the opening position. A half-move is a move by one player, not a move
    /// by one player and a response by the other.
    ///
    /// - parameter index: The index of the move in the game.
    ///
    /// - returns: A String representation of the half-move.
    public func sanMove(at index: Int) -> String {
        return sanMove(for: _moveHistory[index])
    }

    /// The current fullmove number.
    public var fullmoves: UInt {
        return 1 + (UInt(moveCount) / 2)
    }


    /// The captured piece for the last move.
    public var captureForLastMove: Piece? {
        return _moveHistory.last?.capture
    }

    /// The current position for `self`.
//    public var position: Position {
//        return Position(board: board,
//                        playerTurn: playerTurn,
//                        castlingRights: castlingRights,
//                        enPassantTarget: enPassantTarget,
//                        halfmoves: halfmoves,
//                        fullmoves: fullmoves)
//    }

    // MARK: -
    // MARK: Legal Moves: Public Functions

    /// Returns the available moves for the current player.
    public func availableMoves() -> [Move] {
        return _availableMoves(considerHalfmoves: true)
    }

    /// Returns the moves currently available for the piece at `square`.
    public func moves(from square: Square) -> [Move] {
        return _moves(from: square, considerHalfmoves: true)
    }

    /// Returns the moves currently available for the piece at `location`.
    public func moves(from location: Location) -> [Move] {
        return moves(from: Square(location: location))
    }

    /// Returns the moves bitboard currently available for the piece at `square`.
    public func moves(from square: Square) -> Bitboard {
        return _moves(from: square, considerHalfmoves: true)
    }

    /// Returns the moves bitboard currently available for the piece at `location`.
    public func moves(from location: Location) -> Bitboard {
        return moves(from: Square(location: location))
    }

    /// Returns `true` if the move is legal.
    public func canExecute(move: Move) -> Bool {
        return move.target.bitmask.intersects(moves(from: move.origin))
    }

    /// Returns `true` if the current player's king is in check.
    public var isKingInCheck: Bool {
        return _attackersToKing != 0
    }

    /// Returns `true` if the current player's king is checked by two or more pieces.
    public var isKingInMultipleCheck: Bool {
        return _attackersToKing.count > 1
    }

    // MARK: - Legal Moves: Private Functions

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    private func _moves(from square: Square, considerHalfmoves: Bool) -> Bitboard {

        if considerHalfmoves && halfmoves >= 100 {
            return 0
        }

        // No piece -> no bitboard.
        guard let piece = board[square], piece.color == playerTurn else {
            return 0
        }

        // Only the king can move if he is double checked.
        if isKingInMultipleCheck {
            guard piece.kind.isKing else {
                return 0
            }
        }

        let playerBits = board.bitboard(for: playerTurn)
        let enemyBits = board.bitboard(for: playerTurn.inverse())
        let occupiedBits = playerBits | enemyBits
        let emptyBits = ~occupiedBits
        let squareBit = square.bitmask

        var movesBitboard: Bitboard = 0
        let attacks = square.attacks(for: piece, stoppers: occupiedBits)

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

        let player = playerTurn
        for moveSquare in movesBitboard {
            try! _execute(uncheckedMove: Move(origin: square, target: moveSquare), promotion: { .queen })
            if board.attackersToKing(for: player) != 0 {
                movesBitboard[moveSquare] = false
            }
            undoMove()
            _undoHistory.removeLast()
        }

        return movesBitboard
    }

    /// Returns the moves currently available for the piece at `square`, if any.
    private func _moves(from square: Square, considerHalfmoves flag: Bool) -> [Move] {
        return _moves(from: square, considerHalfmoves: flag).moves(from: square)
    }

    /// Returns the available moves for the current player.
    private func _availableMoves(considerHalfmoves flag: Bool) -> [Move] {
        return Array(Square.all.map({ _moves(from: $0, considerHalfmoves: flag) }).joined())
    }

    // MARK: - Move Execution: Public Functions

    /// Executes `move`, updating the state for `self`.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A closure returning a promotion piece kind if a pawn promotion occurs.
    ///
    /// - throws: `ExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move: Move, promotion: () -> Piece.Kind) throws {
        guard canExecute(move: move) else {
            throw ExecutionError.illegalMove(move, playerTurn, board)
        }
        try execute(uncheckedMove: move, promotion: promotion)
        delegate?.game(self, didExecute: move)

        if isKingInCheck {
            guard var historicalMove = _moveHistory.popLast() else { fatalError() }
            if availableMoves().count == 0 {
                historicalMove.setKingStatus(newStatus: .checkmated)
            } else {
                historicalMove.setKingStatus(newStatus: .checked)
            }
            _moveHistory.append(historicalMove)
        }
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A piece kind for a pawn promotion.
    ///
    /// - throws: `ExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move: Move, promotion: Piece.Kind = .queen) throws {
        try execute(move: move, promotion: { promotion })
    }

    /// Executes `move` without checking its legality, updating the state for `self`.
    ///
    /// - warning: Can cause unwanted effects. Should only be used with moves that are known to be legal.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A closure returning a promotion piece kind if a pawn promotion occurs.
    ///
    /// - throws: `ExecutionError` if no piece exists at `move.origin` or if `promotion` is invalid.
    public func execute(uncheckedMove move: Move, promotion: () -> Piece.Kind) throws {
        try _execute(uncheckedMove: move, promotion: promotion)
        if isKingInCheck {
            _attackersToKing = 0
        } else {
            _attackersToKing = board.attackersToKing(for: playerTurn)
        }
        _undoHistory = []
    }

    // MARK: Private Functions

    fileprivate func _execute(uncheckedMove move: Move, promotion: () -> Piece.Kind = { .queen }) throws {
        guard let piece = board[move.origin] else {
            throw ExecutionError.missingPiece(move.origin)
        }
        var endPiece = piece
        var captureSquare = move.target
        var capture = board[captureSquare]
        let rights = castlingRights
        if piece.kind.isPawn {
            if move.target.rank == Rank(endFor: playerTurn) {
                let promotion = promotion()
                guard promotion.isPromotionType() else {
                    throw ExecutionError.invalidPromotion(promotion)
                }
                endPiece = Piece(kind: promotion, color: playerTurn)
            } else if move.target == enPassantTarget {
                capture = Piece(pawn: playerTurn.inverse())
                captureSquare = Square(file: move.target.file, rank: move.origin.rank)
            }
        } else if piece.kind.isRook {
            switch move.origin {
            case .a1: castlingRights.remove(.whiteQueenside)
            case .h1: castlingRights.remove(.whiteKingside)
            case .a8: castlingRights.remove(.blackQueenside)
            case .h8: castlingRights.remove(.blackKingside)
            default:
                break
            }
        } else if piece.kind.isKing {
            for option in castlingRights where option.color == playerTurn {
                castlingRights.remove(option)
            }
            if move.isCastle(for: playerTurn) {
                let (old, new) = move._castleSquares()
                let rook = Piece(rook: playerTurn)
                board[rook][old] = false
                board[rook][new] = true
            }
        }

        var disambiguation: String?
        let attacks = board.attacks(by: piece, to: move.target)
        if piece.kind != .pawn && piece.kind != .king && attacks.count > 1 {

            let sameFile = File.all
                .map { $0.bitmask }
                .reduce(false) { $0 || ($1 | attacks) == $1 }

            let sameRank = Rank.all
                .map { $0.bitmask }
                .reduce(false) { $0 || ($1 | attacks) == $1 }

            switch (sameFile, sameRank) {
            case (true, false): disambiguation = move.origin.rank.description
            case (false, _): disambiguation = String(move.origin.file.character)
            default: disambiguation = String(move.origin.file.character) + move.origin.rank.description
            }

        }

        let newHistoricalMove = HistoricalMove(
            move: move,
            piece: piece,
            capture: capture,
            kingAttackers: _attackersToKing,
            halfmoves: halfmoves,
            rights: rights,
            disambiguation: disambiguation,
            kingStatus: .safe)

        _moveHistory.append(newHistoricalMove)

        if let capture = capture {
            board[capture][captureSquare] = false
        }
        if capture == nil && !piece.kind.isPawn {
            halfmoves += 1
        } else {
            halfmoves = 0
        }
        board[piece][move.origin] = false
        board[endPiece][move.target] = true
        playerTurn.invert()
    }

    // MARK: - Move Undo/Redo: Public Functions

    /// Undoes the previous move and returns it, if any.
    @discardableResult
    public func undoMove() -> Move? {
        return _undoMove()
    }

    /// Redoes the previous undone move and returns it, if any.
    @discardableResult
    public func redoMove() -> Move? {
        return _redoMove()
    }

    /// Returns the last move on the move stack, if any.
    public func moveToUndo() -> Move? {
        return _moveHistory.last?.move
    }

    /// Returns the last move on the undo stack, if any.
    public func moveToRedo() -> Move? {
        return _undoHistory.last?.move
    }

    // MARK: - Move Undo/Redo: Private Functions

    /// Undoes the previous move and returns it, if any.
    private func _undoMove() -> Move? {
        // TODO: disambiguation.
        guard let lastHistoricalMove = _moveHistory.popLast() else { return nil }
        //        guard let (move, piece, capture, attackers, halfmoves, rights, _, _) = _moveHistory.popLast() else {
        //            return nil
        //        }
        var captureSquare = lastHistoricalMove.move.target
        var promotionKind: Piece.Kind? = nil
        if lastHistoricalMove.piece.kind.isPawn {
            if lastHistoricalMove.move.target == enPassantTarget {
                captureSquare = Square(file: lastHistoricalMove.move.target.file,
                                       rank: lastHistoricalMove.move.origin.rank)
            } else if lastHistoricalMove.move.target.rank == Rank(endFor: playerTurn.inverse()), let promotion = board[lastHistoricalMove.move.target] {
                promotionKind = promotion.kind
                board[promotion][lastHistoricalMove.move.target] = false
            }
        } else if lastHistoricalMove.piece.kind.isKing && abs(lastHistoricalMove.move.fileChange) == 2 {
            let (old, new) = lastHistoricalMove.move._castleSquares()
            let rook = Piece(rook: playerTurn.inverse())
            board[rook][old] = true
            board[rook][new] = false
        }
        if let capture = lastHistoricalMove.capture {
            board[capture][captureSquare] = true
        }
        _undoHistory.append((lastHistoricalMove.move, promotionKind, lastHistoricalMove.kingAttackers))
        board[lastHistoricalMove.piece][lastHistoricalMove.move.target] = false
        board[lastHistoricalMove.piece][lastHistoricalMove.move.origin] = true
        playerTurn.invert()
        _attackersToKing = lastHistoricalMove.kingAttackers
        self.halfmoves = lastHistoricalMove.halfmoves
        self.castlingRights = lastHistoricalMove.rights
        return lastHistoricalMove.move
    }

    /// Redoes the previous undone move and returns it, if any.
    private func _redoMove() -> Move? {
        guard let (move, promotion, attackers) = _undoHistory.popLast() else {
            return nil
        }
        try! _execute(uncheckedMove: move, promotion: { promotion ?? .queen })
        _attackersToKing = attackers
        return move
    }

    // MARK: - PGN
    // MARK: Public Initializer

    /// Creates a new chess game.
    ///
    /// - parameter pgn: A PGN instance.
    public convenience init(pgn: PGN) {

        let game = Game()

        game.whitePlayer = Player(name: pgn[PGN.Tag.white], kind: pgn[PGN.Tag.whiteType], elo: pgn[PGN.Tag.whiteElo])
        game.blackPlayer = Player(name: pgn[PGN.Tag.black], kind: pgn[PGN.Tag.blackType], elo: pgn[PGN.Tag.blackElo])
        game.outcome = Outcome(pgn[PGN.Tag.result])

//        for pgnMove in pgn.algebraicMoves {
//            guard let move = game.interpolate(target: pgnMove) else { fatalError() }
//            try! game.execute(move: move)
//        }

        self.init(game: game)
    }

    // MARK: Public Functions

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
        return (board.bitboard(for: piece) & candidates).filter { canExecute(move: Move(origin: $0, target: target)) }.first
    }

    /// Returns the `Move` represented by `pgnMove` or nil if no move is possible.
    ///
    /// - parameter pgnMove: a string representation of the moving piece, the
    ///   target square, and any annotations. For example, given "e3" or "Bf6+".
    public func interpolate(target pgnString: String) -> Move? {

        var algebraic = pgnString.trimmingCharacters(in: CharacterSet(charactersIn: "+=!?#"))

        if algebraic == "O-O" || algebraic == "O-O-O" {
            let side = algebraic == "O-O" ? Board.Side.kingside : Board.Side.queenside
            return Move(castle: playerTurn, side: side)
        }

        let index = algebraic.characters.index(algebraic.endIndex, offsetBy: -2)
        guard let target = Square(algebraic.substring(from: index)) else { return nil }

        var candidateString = algebraic.substring(to: index)

        if
            candidateString.isEmpty,
            let start = origin(for: Piece(pawn: playerTurn), target: target, candidates: target.file.bitmask)
        {
            return Move(origin: start, target: target)
        }

        candidateString = candidateString.trimmingCharacters(in: CharacterSet(charactersIn: "x"))

        if
            candidateString.characters.count == 1,
            let char = candidateString.characters.first,
            let kind = Piece.Kind(character: char)
        {
            let piece = Piece(kind: kind, color: playerTurn)
            if let start = origin(for: piece, target: target, candidates: board.bitboard(for: piece)) {
                return Move(origin: start, target: target)
            }
        }

        if
            candidateString.characters.count == 1,
            let char = candidateString.characters.first,
            let file = File(char),
            let start = origin(for: Piece(pawn: playerTurn), target: target, candidates: file.bitmask)
        {
            return Move(origin: start, target: target)
        }

        if
            candidateString.characters.count == 2,
            let file = File(candidateString.characters[candidateString.index(after: candidateString.startIndex)]),
            let char = candidateString.characters.first,
            let kind = Piece.Kind(character: char),
            let start = origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: file.bitmask)
        {
            return Move(origin: start, target: target)
        }

        if
            candidateString.characters.count == 2,
            let r = Int(String(candidateString.characters[candidateString.index(after: candidateString.startIndex)])),
            let rank = Rank(r),
            let char = candidateString.characters.first,
            let kind = Piece.Kind(character: char),
            let start = origin(for: Piece(kind: kind, color: playerTurn), target: target, candidates: rank.bitmask)
        {
            return Move(origin: start, target: target)
        }

        print("\(algebraic) returns nil")
        return nil

    }

    /// Returns the Standard Algebraic Notation string representation of the
    /// provided `HistoricalMove`.
    public func sanMove(for historicalMove: HistoricalMove) -> String {

        if historicalMove.move.isCastle() {
            return historicalMove.move.isRightward ? "O-O" : "O-O-O"
        }

        var result = ""
        let isCapture = historicalMove.capture != nil

        if let c = historicalMove.piece.kind.character {
            result.append(c)
            if let disambiguation = historicalMove.disambiguation {
                result += disambiguation
            }
        } else if isCapture {
            result.append(historicalMove.move.origin.file.character)
        }

        if isCapture{
            result.append("x")
        }

        result += historicalMove.move.target.description

        switch historicalMove.kingStatus {
        case .checked:
            result += "+"
        case .checkmated:
            result += "#"
        default:
            break
        }

        return result
    }

    /**
     Returns
     */
    public func sanMove(for historicalIndex: Int) -> String {
        return sanMove(for: moveHistory[historicalIndex])
    }

    /**
     Returns a `Dictionary` where `Key` = `PGN.Tag` and `Value` = `String` of
     the PGN tag pairs describing `self`.
     */
    public func tagPairs() -> Dictionary<String, String> {
        var pairs: Dictionary<String, String> = [:]
        pairs[PGN.Tag.white.rawValue] = whitePlayer.name
        pairs[PGN.Tag.black.rawValue] = blackPlayer.name
//        pairs[PGN.Tag.result.rawValue] = outcome?.description
        return pairs
    }
    
    /**
     Returns the PGN representation of `self`.
     */
    public var pgn: PGN {
        return PGN(tagPairs: tagPairs(), moves: _moveHistory.map(sanMove))
    }
    
}

// MARK: -
// MARK: Game Delegate

public protocol GameDelegate {
    func game(_: Game, didExecute move: Move) -> ()
}
