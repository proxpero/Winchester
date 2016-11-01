//
//  TitleViewDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

struct TitleViewDataSource: TitleViewModel {

    private let game: Game

    init(for game: Game) {
        self.game = game
    }

    var white: Player {
        return game.whitePlayer
    }

    var black: Player {
        return game.blackPlayer
    }

    var outcome: Outcome {
        return game.outcome
    }
    
}