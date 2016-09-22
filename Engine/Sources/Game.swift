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
    
    // MARK: - Public Stored Properties

    /// The game's delegate.
    public var delegate: GameDelegate?

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

    // MARK: - Private Stored Properties

    /// The starting position.
    private var _startingPosition: Position

    /// All of the conducted moves in the game.
    private var _history: Array<HistoryItem>

    /// All of the undone moves in the game.
    private var _undoHistory: [(move: Move, promotion: Piece.Kind?, kingAttackers: Bitboard)]

    // MARK: - Public Initializers

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter variant: The game's chess variant. Default is standard.
    public init(whitePlayer: Player = Player(), blackPlayer: Player = Player(), startingPosition: Position = Position()) {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self._startingPosition = startingPosition
        self._history = []
        self._undoHistory = []
    }

    // MARK: - Private Initializers

    /// Create a game from another game.
    private init(game: Game) {
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self._startingPosition = game._startingPosition
        self._history = game._history
        self._undoHistory = game._undoHistory
    }

    // MARK: - Public API

    public func availableTargets(for color: Color) -> [Square] {
        return currentPosition._legalTargetSquares(for: color, considerHalfmoves: false)
    }

    public func availableCaptures(for color: Color) -> [Square] {
        return currentPosition._legalCaptures(for: color)
    }

    public func availableTargets(forPieceAt square: Square) -> [Square] {
        return currentPosition._legalTargetSquares(from: square, considerHalfmoves: false)
    }

    public var squaresAttackingKing: [Square] {
        return currentPosition._attackersToKing.map { $0 }
    }

    public func guardingMoves(for square: Square) -> [Move] {
        return currentPosition._uncheckedGuardingMoves
    }

    public var gaurdedSquares: [Square] {
        return currentPosition._uncheckedGuardedSquares
    }

    public func undefended(by color: Color) -> [Square] {
        return []
    }

    public func execute(move: Move, promotion: Piece? = nil) {

        // execute move
        guard let newHistoryItem = currentPosition._execute(uncheckedMove: move, promotion: promotion) else {
            fatalError("Could not execute move: \(move.description)")
        }
        _history.append(newHistoryItem)
        self.delegate?.game(self, didExecute: move, withPromotion: promotion)
    }

    // MARK: - Public Computed Properties

    public var currentPosition: Position {
        guard let lastItem = _history.last else {
            return _startingPosition
        }
        return lastItem.position
    }

    public var history: Array<HistoryItem> {
        return _history
    }

    /// The number of executed moves.
    public var moveCount: Int {
        return _history.count
    }

    /// All of the moves played in the game.
    public var playedMoves: [Move] {
        return _history.map({ $0.move })
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
        return _history.last?.move
    }

    /// Returns the last move on the undo stack, if any.
    public func moveToRedo() -> Move? {
        return _undoHistory.last?.move
    }

    // MARK: - Move Undo/Redo: Private Functions

    /// Undoes the previous move and returns it, if any.
    private func _undoMove() -> Move? {
        return nil
    }

    /// Redoes the previous undone move and returns it, if any.
    private func _redoMove() -> Move? {
        return nil
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
        return nil
//        return (currentPosition.board.bitboard(for: piece) & candidates).filter { currentPosition._canExecute(move: Move(origin: $0, target: target)) }.first
    }

    /// Returns the `Move` represented by `pgnMove` or nil if no move is possible.
    ///
    /// - parameter pgnMove: a string representation of the moving piece, the
    ///   target square, and any annotations. For example, given "e3" or "Bf6+".
    public func interpolate(target pgnString: String) -> Move? {
        return nil

    }

    /**
     Returns a `Dictionary` where `Key` = `PGN.Tag` and `Value` = `String` of
     the PGN tag pairs describing `self`.
     */
    public func tagPairs() -> Dictionary<String, String> {
        var pairs: Dictionary<String, String> = [:]
        pairs[PGN.Tag.white.rawValue] = whitePlayer.name
        pairs[PGN.Tag.black.rawValue] = blackPlayer.name
//        pairs[PGN.Tag.result.rawValue] = currentPosition.outcome.description
        return pairs
    }
    
    /**
     Returns the PGN representation of `self`.
     */
//    public var pgn: PGN {
//        return PGN(tagPairs: tagPairs(), moves: _history.map(sanMove))
//    }

}

// MARK: -
// MARK: Game Delegate

public protocol GameDelegate {
    func game(_: Game, didExecute move: Move, withPromotion: Piece?) -> ()
}
