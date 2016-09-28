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

    public weak var delegate: GameDelegate?

    /// The game's move index.
    public var moveIndex: Int

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

    /// The game's eco. https://en.wikipedia.org/wiki/Encyclopaedia_of_Chess_Openings
    public var eco: ECO?

    /// The game's outcome.
    public var outcome: Outcome

    // MARK: - Private Stored Properties

    /// The starting position.
    private var _startingPosition: Position

    /// All of the conducted moves in the game.
    private var _history: Array<HistoryItem>

    /// All of the undone moves in the game.
    private var _undoHistory: Array<HistoryItem>

    // MARK: - Public Initializers

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter startingPosition: The games's starting position. Default is standard.
    public init(whitePlayer: Player = Player(), blackPlayer: Player = Player(), startingPosition: Position = Position(), moveIndex: Int = 0) {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.moveIndex = moveIndex
        self.outcome = .undetermined
        self._startingPosition = startingPosition
        self._history = []
        self._undoHistory = []
    }

    // MARK: - Private Initializers

    /// Create a game from another game.
    private init(game: Game) {
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self.outcome = game.outcome
        self.moveIndex = game.moveIndex
        self._startingPosition = game._startingPosition
        self._history = game._history
        self._undoHistory = game._undoHistory
    }

    // MARK: - Public API

    @discardableResult
    public func move(to index: Int) -> [HistoryItem] {
        let diff = _history.count - index
        if diff == 0 { return [] }
        if diff > 0 {
            return _reverse(to: index)
        } else {
            return _advance(to: index)
        }
    }

    public var startIndex: Int {
        return _history.startIndex
    }

    public var lastIndex: Int {
        return _undoHistory.endIndex
    }

    private func _reverse(to index: Int) -> [HistoryItem] {
        guard index >= 0 else { fatalError() }
        return stride(from: _history.count, to: index, by: -1).flatMap { _ in undo() }
    }

    private func _advance(to index: Int) -> [HistoryItem] {
        guard index <= _undoHistory.count else { fatalError() }
        return (0 ..< index).flatMap { _ in redo() }
    }

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

    public func attackedOccupations(for color: Color) -> [Square] {
        return currentPosition._attackedOccupations(for: color)
    }

    public func defendedOccupations(for color: Color) -> [Square] {
        return currentPosition._defendedOccupations(for: color)
    }

    public func undefendedOccupations(for color: Color) -> [Square] {
        return currentPosition._undefendedOccupations(for: color)
    }

    public func threatenedEnemies(for color: Color) -> [Square] {
        return currentPosition._threatenedEnemies(for: color)
    }

    public func attackers(targeting square: Square, for color: Color) -> ([Square]) {
        return currentPosition._attackers(targeting: square, for: color)
    }

    public func execute(sanMoves: String) throws {
        for sanMove in sanMoves.components(separatedBy: " ") {
            guard let (move, promotion) = currentPosition.move(forSan: sanMove)
            else { fatalError("I should throw an error") }
            try execute(move: move, promotion: promotion)
        }
    }

    public func execute(move: Move, promotion: Piece? = nil) throws {

        // execute move
        guard let newHistoryItem = currentPosition._execute(uncheckedMove: move, promotion: promotion) else {
            fatalError("Could not execute move: \(move.description)")
        }
        _history.append(newHistoryItem)

        if let e = ECO.codes[sanMoves.joined(separator: " ")] {
            eco = e
        }

        delegate?.game(self, didExecute: move, with: newHistoryItem.capture, with: promotion)
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

    public var undoHistory: Array<HistoryItem> {
        return _undoHistory
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

    @discardableResult
    public func undo() -> HistoryItem? {
        if let last = _history.popLast() {
            _undoHistory.append(last)
            return last
        }
        return nil
    }

    @discardableResult
    public func redo() -> HistoryItem? {
        if let last = _undoHistory.popLast() {
            _history.append(last)
            return last
        }
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
        game.outcome = pgn.outcome

        do {
            try game.execute(sanMoves: pgn.sanMoves.joined(separator: " "))
        } catch {
            fatalError("could not parse san move: \(pgn.sanMoves)")
        }
        self.init(game: game)
    }

    private static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()

    /// Returns a `Dictionary` where `Key` = `PGN.Tag` and `Value` = `String` of
    /// the PGN tag pairs describing `self`.
    public func tagPairs() -> Dictionary<String, String> {
        var pairs: Dictionary<String, String> = [:]
        pairs[PGN.Tag.white.rawValue] = whitePlayer.name
        pairs[PGN.Tag.black.rawValue] = blackPlayer.name
        pairs[PGN.Tag.result.rawValue] = outcome.description
        if let eco = eco {
            pairs[PGN.Tag.eco.rawValue] = eco.code.rawValue
        }
        pairs[PGN.Tag.date.rawValue] = Game.dateFormatter.string(from: Date())
        return pairs
    }
    
    /**
     Returns the PGN representation of `self`.
     */
    public var pgn: PGN {
        return PGN(tagPairs: tagPairs(), moves: _history.map({ $0.sanMove }))
    }

}

// MARK: - Game Delegate

public protocol GameDelegate: class {
    func game(_: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) -> ()
    func game(_: Game, didAdvance items: [HistoryItem]) -> ()
    func game(_: Game, didReverse items: [HistoryItem]) -> ()
}
