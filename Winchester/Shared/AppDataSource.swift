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

public func userGames() -> [Game] {
    let files = UserDefaults.standard.array(forKey: "user-games") as? [String] ?? [String]()
    return files
        .map { try! PGN(parse: $0) }
        .map { Game(pgn: $0) }
}

public func classicGames() -> [Game] {
    let files = UserDefaults.standard.array(forKey: "classic-games") as? [String] ?? _files.flatMap { Bundle.main.url(forResource: $0, withExtension: "pgn") }
        .map { try! String(contentsOf: $0) }
    return files
        .map { try! PGN(parse: $0) }
        .map { Game(pgn: $0) }
}

