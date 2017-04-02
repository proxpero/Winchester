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
    
    /// The game's delegate
    public weak var delegate: GameDelegate?

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

    public var eco: ECO? {
        guard moveIndex > 0 else { return nil }
        return ECO.eco(for: sanMoves.joined(separator: " "))
    }

    /// The game's date.
    public var date: Date?

    /// An array that stores a sequence of positions.
    var events: Array<Event>

    /// The index of the current position.
    public var moveIndex: Array<Event>.Index {
        didSet {
            delegate?.game(self, moveIndexDidChange: oldValue, to: moveIndex)
        }
    }

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter startingPosition: The games's starting position. Default is standard.
    public init(
        whitePlayer: Player = Player(),
        blackPlayer: Player = Player(),
        date: Date? = Date(),
        startingPosition: Position = Position(),
        events: Array<Event> = [],
        moveIndex: Array<Event>.Index = 0)
    {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.date = date
        self.events = [Event(position: startingPosition, history: nil)]
        self.moveIndex = moveIndex
    }

    /// Create a game from another game.
    convenience init(game: Game) {
        self.init(
            whitePlayer: game.whitePlayer,
            blackPlayer: game.blackPlayer,
            date: game.date
        )
        self.events = game.events
        self.moveIndex = game.moveIndex
    }

}


