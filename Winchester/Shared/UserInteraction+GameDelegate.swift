//
//  UserInteraction+GameDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

protocol GameDelegateType: GameDelegate {

    var traversalHandler: Game.TraversalHandler { get }
    func gameDidTraverse(_ items: [HistoryItem], in direction: Direction)

}

extension GameDelegateType {

    func gameDidTraverse(_ items: [HistoryItem], in direction: Direction) {
        traversalHandler.userDidTraverse(direction, with: items)
    }

    func gameDidExecute(_ move: Move, with capture: Capture?, with promotion: Piece?) {
        // Notify HistoryView so that a new cell can be presented.
    }
}


