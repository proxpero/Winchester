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

/// A chess game.
public class Game {
    
    // MARK: - Public Stored Properties

    /// The game's delegate
    public weak var delegate: GameDelegate?

    /// The unique id for this game.
    public let id: String

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

//    public var eco: ECO?

    /// The game's date.
    public var date: Date?

    // MARK: - Private Stored Properties

    /// The starting position.
//    var _startingPosition: Position

    var _currentIndex: Int?

    var _items: Array<HistoryItem>

    // MARK: - Public Initializers

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter startingPosition: The games's starting position. Default is standard.
    public init(
        id: String = UUID().uuidString,
        whitePlayer: Player = Player(),
        blackPlayer: Player = Player(),
        date: Date? = Date(),
        startingPosition: Position = Position())
    {
        self.id = id
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.date = date
//        self._startingPosition = startingPosition
        let initialItem = HistoryItem(position: startingPosition, move: nil, piece: nil, capture: nil, promotion: nil, sanMove: nil)
        self._items = [initialItem]
        self._currentIndex = nil
    }

    // MARK: - Internal Initializers

    /// Create a game from another game.
    convenience init(game: Game) {
        self.init(
            id: game.id,
            whitePlayer: game.whitePlayer,
            blackPlayer: game.blackPlayer,
            date: game.date
//            startingPosition: game._startingPosition
        )

        self._items = game._items
        self._currentIndex = game._currentIndex
    }

}

extension Game {
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


