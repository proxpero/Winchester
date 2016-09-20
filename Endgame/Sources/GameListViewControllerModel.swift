//
//  GameListViewControllerModel.swift
//  Endgame
//
//  Created by Todd Olsen on 9/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine

struct GameListViewControllerModel: Equatable {

    fileprivate var _userGames: [PGN]
    var userGames: [PGN] { return _userGames }

    // MARK: Initialization

    init(userGames: [PGN]) {
        _userGames = userGames
    }

    // MARK: Entry points to modify/query underlying model.

    mutating func append(_ game: PGN) {
        _userGames.append(game)
    }

    mutating func removeLast() -> PGN {
        return _userGames.removeLast()
    }

    subscript(gameAt index: Int) -> PGN {
        get {
            return _userGames[index]
        }

        set {
            _userGames[index] = newValue
        }
    }



}

func ==(_ lhs: GameListViewControllerModel, _ rhs: GameListViewControllerModel) -> Bool {
    return lhs._userGames == rhs._userGames
}

