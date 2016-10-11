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

    private var _currentIndex: Int?
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
//        self._history = []
//        self._undoHistory = []
        self._items = []
        self._currentIndex = nil
    }

    // MARK: - Private Initializers

    /// Create a game from another game.
    private init(game: Game) {
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self.outcome = game.outcome
        self._startingPosition = game._startingPosition
//        self._history = game._history
//        self._undoHistory = game._undoHistory
        self._items = game._items
        self._currentIndex = game._currentIndex
    }

    // MARK: - Public API

//    @discardableResult
//    public func move(to targetIndex: Int) -> (direction: Direction, items: [HistoryItem]) {
//        let direction = Direction(currentIndex: _history.endIndex, targetIndex: targetIndex)
//        let items: [HistoryItem]
//        switch direction {
//        case .forward(let distance):
//            items = (0 ..< distance).flatMap { _ in redo() }
//        case .reverse(let distance):
//            items = (0 ..< distance).flatMap { _ in undo() }
//        }
//        return (direction, items)
//    }

//    public func item(at index: Int) -> HistoryItem? {
//        guard index >= self.startIndex && index < self.endIndex else {
//            return nil
//        }
//        return items[index]
//        if index < _history.endIndex {
//            return _history[index]
//        } else {
//            let i = _history.endIndex + _undoHistory.endIndex - index
//            let i = _undoHistory.endIndex - (index - _history.endIndex)
//            print("i=\(i), index=\(index)")
//            print("item=\(_undoHistory[i].sanMove)")
//            return _undoHistory[i]
//        }
//    }

    public var playerTurn: Color {
        return currentPosition.playerTurn
    }

    public func isPromotion(for move: Move) -> Bool {
        return currentPosition.board[move.target]?.kind == .pawn && move.reachesEndRank(for: playerTurn)
    }

    public var items: [HistoryItem] {
        return _items
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

//    public var lastMove: Move? {
//        return playedMoves.last
//    }

//    public var history: Array<HistoryItem> {
//        return _history
//    }

//    public var undoHistory: Array<HistoryItem> {
//        return _undoHistory
//    }

    /// The number of executed moves.
//    public var moveCount: Int {
//        return _history.count
//    }

    /// All of the moves played in the game.
//    public var playedMoves: [Move] {
//        return _history.map({ $0.move })
//    }

//    public var sanMoves: [String] {
//        return _history.map { $0.sanMove }
//    }

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
//        if position < _history.endIndex {
//            return _history[position]
//        } else {
//            return _undoHistory[position - _history.count]
//        }
    }

    // MARK: - Move Undo/Redo: Public Functions

    /// Decrements the currentIndex and returns the undone `HistoryItem`.
    @discardableResult
    public func undo(count: Int = 1) -> HistoryItem? {
        guard let current = _currentIndex, current > count - 1 else {
            return nil
        }
        let newIndex = current - count
        _currentIndex = newIndex
        return _items[newIndex]

//        if let last = _history.popLast() {
//            _undoHistory.append(last)
//            return last
//        }
//        return nil
    }

    /// Increments the currentIndex and returns the redone `HistoryItem`.
    @discardableResult
    public func redo(count: Int = 1) -> HistoryItem {
        let newIndex: Int
        if let current = _currentIndex {
            newIndex = current + count
        } else {
            newIndex = count - 1
        }
        _currentIndex = newIndex
        precondition(newIndex < _items.endIndex)
        return _items[newIndex]

//        if let last = _undoHistory.popLast() {
//            _history.append(last)
//            return last
//        }
//        return nil
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
    case forward(Int)
    case reverse(Int)

    public var isForward: Bool {
        switch self {
        case .forward(_):
            return true
        default:
            return false
        }
    }

    public var isReverse: Bool {
        switch self {
        case .reverse(_):
            return true
        default:
            return false
        }
    }

    init(currentIndex: Int, targetIndex: Int) {
        let distance = abs(currentIndex - targetIndex)
        if currentIndex > targetIndex { self = .reverse(distance) }
        else { self = .forward(distance) }
    }

    public static func == (lhs: Direction, rhs: Direction) -> Bool {
        switch (lhs, rhs) {
        case (.forward(let a), .forward(let b)):
            return a == b
        case (.reverse(let a), .reverse(let b)):
            return a == b
        default: return false
        }
    }
}
