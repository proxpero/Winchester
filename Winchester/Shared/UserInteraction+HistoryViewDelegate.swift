//
//  UserInteraction+HistoryViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/6/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

protocol HistoryViewDelegateType: HistoryViewDelegate {
    weak var game: Game? { get }
    func userDidSelectHistoryItem(at itemIndex: Int?)
}

extension HistoryViewDelegateType {

    func userDidSelectHistoryItem(at itemIndex: Int?) {
        guard let game = game else { fatalError("Expected a game") }
        game.setIndex(to: itemIndex)
    }
    
}
