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

    // MARK: - Subscripts

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

    public func execute(sanMove: String) throws {
        guard let (move, promotion) = currentPosition.move(forSan: sanMove)
        else { fatalError("I should throw an error") }
        try execute(move: move, promotion: promotion)
    }

    public func execute(move: Move, promotion: Piece? = nil) throws {

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

    public var sanMoves: [String] {
        return _history.map { $0.sanMove }
    }

    // MARK: - Move Undo/Redo: Public Functions


    // MARK: - PGN
    // MARK: Public Initializer

    /// Creates a new chess game.
    ///
    /// - parameter pgn: A PGN instance.
    public convenience init(pgn: PGN) {

        let game = Game()

        game.whitePlayer = Player(name: pgn[PGN.Tag.white], kind: pgn[PGN.Tag.whiteType], elo: pgn[PGN.Tag.whiteElo])
        game.blackPlayer = Player(name: pgn[PGN.Tag.black], kind: pgn[PGN.Tag.blackType], elo: pgn[PGN.Tag.blackElo])

        for sanMove in pgn.sanMoves {
            do {
                try game.execute(sanMove: sanMove)
            } catch {
                fatalError("could not parse san move: \(sanMove)")
            }
        }

        self.init(game: game)
    }

    /// Returns a `Dictionary` where `Key` = `PGN.Tag` and `Value` = `String` of
    /// the PGN tag pairs describing `self`.
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
