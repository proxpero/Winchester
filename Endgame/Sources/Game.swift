//
//  Game.swift
//  Endgame
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

    public var delegate: GameDelegate?

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

    public var eco: ECO?

    /// The game's outcome.
    public var outcome: Outcome

    /// The game's date.
    public var date: Date?

    // MARK: - Private Stored Properties

    /// The starting position.
    fileprivate var _startingPosition: Position

    internal var _currentIndex: Int?
    fileprivate var _items: Array<HistoryItem>

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
        self.date = Date()
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
        self.date = game.date
        self._startingPosition = game._startingPosition
        self._items = game._items
        self._currentIndex = game._currentIndex
    }

}

extension Game {

    // MARK: - Public API

    /// Returns the color of the player whose turn it is.
    public var playerTurn: Color {
        return currentPosition.playerTurn
    }

    public var currentIndex: Int? {
        return _currentIndex
    }

    /// Returns the last move of the position.
    public var latestMove: Move? {
        guard let current = _currentIndex else {
            return nil
        }
        return _items[current].move
    }

    public var lastSanMove: String? {
        guard let current = _currentIndex else {
            return nil
        }
        return _items[current].sanMove
    }

    /// Returns whether `move` is a promotion.
    public func isPromotion(for move: Move) -> Bool {
        return currentPosition.board[move.target]?.kind == .pawn && move.reachesEndRank(for: playerTurn)
    }

    /// Returns the squares a side could potentially occupy.
    ///
    /// - parameter color: The player on whose behalf the computation is made.
    ///
    /// - returns: An array of `Square`s.
    public func availableTargets(for color: Color) -> [Square] {
        return currentPosition._legalTargetSquares(for: color)
    }

    public func availableCaptures(for color: Color) -> [Square] {
        return currentPosition._legalCaptures(for: color)
    }

    public func availableTargets(forPieceAt square: Square) -> [Square] {
        return currentPosition._legalTargetSquares(from: square)
    }

    public func availableCaptures(forPieceAt square: Square) -> [Square] {
        return currentPosition._legalCaptures(forPieceAt: square)
    }

    public var squaresAttackingKing: [Square] {
        return currentPosition._attackersToKing.map { $0 }
    }

    public func movesAttackingKing() -> [Move] {
        guard let kingSquare = currentPosition.board.squareForKing(for: currentPosition.playerTurn) else { return [] }
        return currentPosition._attackersToKing.map { Move(origin: $0, target: kingSquare) }
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
        delegate?.game(self, didAppend: newHistoryItem, at: _currentIndex)

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
        guard let count = _currentIndex else { return [] }
        return undo(count: count + 1)
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
            return ArraySlice<HistoryItem>()
//            fatalError("Cannot undo the initial position")
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
    ///   A `nil` result indicates that nothing needs doing.
    public func setIndex(to newIndex: Int?) {

        let direction: Direction
        let slice: ArraySlice<HistoryItem>

        switch (_currentIndex, newIndex) {
        case (nil, nil):
            return
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
        delegate?.game(self, didTraverse: Array(slice), in: direction)
    }

}

extension Game: Collection { }

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
