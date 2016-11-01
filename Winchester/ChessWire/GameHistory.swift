//
//  GameHistory.swift
//  Endgame
//
//  Created by Todd Olsen on 9/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Engine

struct GameHistory {
    // MARK: Properties

    private static let maximumHistorySize = 50

    private static let userDefaultsKey = "chessGames"

    /// An array of previously created 'Game's.
    fileprivate var games: [Game]

    var count: Int {
        return games.count
    }

    subscript(index: Int) -> Game {
        return games[index]
    }

    // MARK: Initialization

    private init(games: [Game]) {
        self.games = games
    }

    /// Loads previously created `Game`s and returns a `GameHistory` instance.
    static func load() -> GameHistory {
        var games = [Game]()
        let defaults = UserDefaults.standard

        if let savedGames = defaults.object(forKey: GameHistory.userDefaultsKey) as? [String] {
            games = savedGames.flatMap { urlString in
                guard let url = URL(string: urlString) else { return nil }
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }
                return Game(queryItems: queryItems)
            }
        }

        return GameHistory(games: games)
    }

    /// Saves the history.
    func save() {
        // Save a maximum number of games.
        let gamesToSave = games.suffix(GameHistory.maximumHistorySize)

        // Map the games to an array of URL strings.
        let gameURLStrings: [String] = gamesToSave.flatMap { game in
            var components = URLComponents()
            components.queryItems = [game.queryItem]
            return components.url?.absoluteString
        }

        let defaults = UserDefaults.standard
        defaults.set(gameURLStrings, forKey: GameHistory.userDefaultsKey)
    }

    mutating func append(_ game: Game) {
        var newGames = self.games.filter { $0.queryItem != game.queryItem }
        newGames.append(game)
        games = newGames
    }
}

extension GameHistory: Sequence {
    typealias Iterator = AnyIterator<Game>

    func makeIterator() -> Iterator {
        var index = 0

        return Iterator {
            guard index < self.games.count else { return nil }

            let game = self.games[index]
            index += 1

            return game
        }
    }
}
