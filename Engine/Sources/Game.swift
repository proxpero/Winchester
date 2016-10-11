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
public typealias IndexResult = (direction: Direction, items: Array<HistoryItem>)

/// A chess game.
public class Game {
    
    // MARK: - Public Stored Properties

    public weak var delegate: GameDelegate?

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

    internal var _currentIndex: Int?
    private var _items: Array<HistoryItem>

    /// All of the conducted moves in the game.
//    private var _history: Array<HistoryItem>

    /// All of the undone moves in the game.
//    private var _undoHistory: Array<HistoryItem>

    // MARK: - Public Initializers

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter startingPosition: The games's starting position. Default is standard.
    public init(
        whitePlayer: Player = Player(),
        blackPlayer: Player = Player(),
        startingPosition: Position = Position(),
        moveIndex: Int = 0)
    {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.outcome = .undetermined
        self._startingPosition = startingPosition
        self._items = []
        self._currentIndex = nil
    }

    // MARK: - Private Initializers

    /// Create a game from another game.
    internal init(game: Game) {
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self.outcome = game.outcome
        self._startingPosition = game._startingPosition
        self._items = game._items
        self._currentIndex = game._currentIndex
    }

    // MARK: - Public API

    public var playerTurn: Color {
        return currentPosition.playerTurn
    }

    public var latestMove: Move? {
        guard let current = _currentIndex else {
            return nil
        }
        return _items[current].move
    }

    public func isPromotion(for move: Move) -> Bool {
        return currentPosition.board[move.target]?.kind == .pawn && move.reachesEndRank(for: playerTurn)
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

    /// Execute `move`.  
    public func execute(move: Move, promotion: Piece? = nil) throws {

        // execute move
        guard let newHistoryItem = currentPosition._execute(uncheckedMove: move, promotion: promotion) else {
            fatalError("Could not execute move: \(move.description)")
        }

        // Remove "undone moves" from the items array.
        if let current = _currentIndex, current + 1 < endIndex {
            _items.removeSubrange((current + 1)..<_items.endIndex)
        }
        _items.append(newHistoryItem)
        _currentIndex = _items.endIndex - 1

        let key = self.map { $0.sanMove }.joined(separator: " ")
        if let e = ECO.codes[key] {
            eco = e
        }

        delegate?.game(self, didExecute: move, with: newHistoryItem.capture, with: promotion)
    }

    // MARK: - Public Computed Properties

    public var currentPosition: Position {
        guard let current = _currentIndex else {
            return _startingPosition
        }
        return _items[current].position
    }

    // MARK: - Collection Protocol Conformance

    public var startIndex: Int {
        return _items.startIndex
    }

    public var endIndex: Int {
        return _items.endIndex
    }

    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }

    public subscript(position: Int) -> HistoryItem {
        precondition(_items.indices.contains(position), "Index out of bounds")
        return _items[position]
    }

    // MARK: - Move Undo/Redo: Public Functions

    /// Sets the game's currentIndex to the starting position.
    @discardableResult
    public func undoAll() -> ArraySlice<HistoryItem> {
        return undo(count: _items.count)
    }

    /// Sets the game's currentIndex to the ending position.
    ///
    /// - returns: A corresponding slice of `items`. 
    @discardableResult
    public func redoAll() -> ArraySlice<HistoryItem> {
        return redo(count: _items.count)
    }

    /// Decrements `currentIndex` and returns the undone history items in the
    /// order in which they must be executed in order to recreate the redone state.
    ///
    /// - parameter count: The number of moves to undo. Default is 1.
    ///
    /// - returns: An optional array of history items.
    @discardableResult
    public func undo(count: Int = 1) -> ArraySlice<HistoryItem> {
        guard let current = _currentIndex else {
            fatalError("Cannot undo the initial position")
        }
        let newIndex: Int?
        let range: Range<Int>

        if count == current + 1 {
            newIndex = nil
            range = startIndex ..< current+1
        } else {
            newIndex = current - count
            range = (newIndex!+1)..<(current+1)
        }

        _currentIndex = newIndex
//        precondition(_items.indices.overlaps(range), "Error: Trying to undo more items than are in contained in items.")
        return _items[range]
    }

    /// Increments the currentIndex and returns the redone history items in the order
    /// in which they must executed in order to recreate the undone state.
    ///
    /// - parameter count: The number of moves to redo. Default is 1.
    ///
    /// - returns: An optional array of history items.
    @discardableResult
    public func redo(count: Int = 1) -> ArraySlice<HistoryItem> {
        let newIndex: Int
        let range: Range<Int>
        if let current = _currentIndex {
            newIndex = current + count
            range = (current+1) ..< (newIndex+1)
        } else {
            newIndex = count - 1
            range = _items.startIndex ..< count
        }
        _currentIndex = newIndex
        if !_items.indices.contains(range.lowerBound) || !_items.indices.contains(range.upperBound-1) {
            return []
        }
        return _items[range]
    }

    /// Sets the current index of `self`.
    ///
    /// - parameter newIndex: The index to set currentIndex to. If nil then
    ///   the game is reset to the starting position.
    ///
    /// - returns: A tuple of the `direction` in which the move happens
    ///   and an array of `HistoryItem`s representing the difference in state.
    public func settingIndex(to newIndex: Int?) -> IndexResult? {

        let direction: Direction
        let slice: ArraySlice<HistoryItem>

        switch (_currentIndex, newIndex) {
        case (nil, nil):
            return nil
        case (nil, _):
            direction = .redo
            slice = self.redo(count: newIndex! + 1)
        case (_, nil):
            direction = .undo
            slice = self.undo(count: abs(_currentIndex! + 1))
        default:
            direction = (_currentIndex! < newIndex!) ? .redo : .undo
            let count = abs(_currentIndex! - newIndex!)
            switch direction {
            case .redo: slice = self.redo(count: count)
            case .undo: slice = self.undo(count: count)
            }
        }

        return (direction, Array(slice))
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
            fatalError("could not parse san moves: \(pgn.sanMoves)")
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
        return PGN(tagPairs: tagPairs(), moves: self.map({ $0.sanMove }))
    }

}

extension Game: Collection {

}

// MARK: - Game Delegate

public protocol GameDelegate: class {
    func game(_: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) -> ()
    func game(_: Game, didAdvance items: [HistoryItem]) -> ()
    func game(_: Game, didReverse items: [HistoryItem]) -> ()
}

public enum Direction: Equatable {
    case undo
    case redo

    public var isUndo: Bool {
        switch self {
        case .undo:
            return true
        default:
            return false
        }
    }

    public var isRedo: Bool {
        switch self {
        case .redo:
            return true
        default:
            return false
        }
    }

    public init?(currentIndex: Int?, newIndex: Int?) {

        switch (currentIndex, newIndex) {
        case (nil, nil): return nil
        case (nil, _): self = .redo
        case (_, nil): self = .undo
        default:
            self = (currentIndex! < newIndex!) ? .undo : .redo
        }

    }
}
