//
//  BoardArrowsCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

final class BoardArrowsCoordinator {

    let showLastMove: (Move?) -> Void
    let addArrow: (Move, ArrowType) -> Void

    init(showLastMove: @escaping (Move?) -> Void, addArrow: @escaping (Move, ArrowType) -> Void) {
        self.showLastMove = showLastMove
        self.addArrow = addArrow
    }

    func showArrows(for game: Game) {
        if let lastMove = game.latestMove {
            showLastMove(lastMove)
        }
    }


}
