//
//  Opponent.swift
//  Winchester
//
//  Created by Todd Olsen on 11/20/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

struct Opponent {

    let id: String
    let history: GameHistory

    init(id: String) {
        self.id = id
        self.history = GameHistory.load(with: id)
    }


}
