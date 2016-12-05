//
//  AppDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 11/8/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

let _files = ["fischer v fine", "fischer v thomason", "fischer v warner", "reti v rubenstein", "shirov v polgar"]

public typealias Games = Dictionary<String, Game>

public func userGames() -> Games {
    let files = UserDefaults.standard.dictionary(forKey: "user-games") as? Dictionary<String, String> ?? Dictionary<String, String>()
    var games = Games()
    for (key, value) in files {
        let pgn = try! PGN(parse: value)
        games[key] = Game(pgn: pgn)
    }
    return games
}

public func classicGames() -> [Game] {
    let files = UserDefaults.standard.array(forKey: "classic-games") as? [String] ?? _files.flatMap { Bundle.main.url(forResource: $0, withExtension: "pgn") }
        .map { try! String(contentsOf: $0) }
    return files
        .map { try! PGN(parse: $0) }
        .map { Game(pgn: $0) }
}

