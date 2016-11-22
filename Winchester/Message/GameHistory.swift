//
//  GameHistory.swift
//  Winchester
//
//  Created by Todd Olsen on 11/20/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

struct GameHistory {

    private static let maximumSize = 50

    private static let userDefaultsKey = "opponentsDictionary"

    private let opponentKey: String

    fileprivate var games: [Game]

    var count: Int {
        return games.count
    }

    subscript(index: Int) -> Game {
        return games[index]
    }

    private init(_ games: [Game], opponentKey: String) {
        self.games = games
        self.opponentKey = opponentKey
    }

    func save() {
        // Save the maximun number of games. 
        let gamesToSave = games.suffix(GameHistory.maximumSize)

        // Map the games to an array of pgns. 
        let pgns: [String] = gamesToSave.map { $0.pgn.exported() }
        let defaults = UserDefaults.standard
        guard var opponents = defaults.dictionary(forKey: GameHistory.userDefaultsKey) as? Dictionary<String, [String]> else { fatalError("Could not save history") }
        opponents[opponentKey] = pgns
        defaults.set(opponents, forKey: GameHistory.userDefaultsKey)
    }

    static func load(with opponentKey: String) -> GameHistory {

        let defaults = UserDefaults.standard
        guard
            let opponents = defaults.object(forKey: GameHistory.userDefaultsKey) as? Dictionary<String, [String]>,
            let pgns = opponents[opponentKey],
            !pgns.isEmpty
        else {
            return GameHistory([], opponentKey: opponentKey)
        }

        do {
            let games = try pgns.map(PGN.init).map(Game.init)
            return GameHistory(games, opponentKey: opponentKey)
        } catch {
            fatalError("could not create a game from \(pgns)")
        }

    }
}

extension GameHistory: Sequence {

    func makeIterator() -> AnyIterator<Game> {

        var index = 0

        return Iterator {
            guard index < self.games.count else { return nil }

            let game = self.games[index]
            index += 1

            return game
        }
    }
}
