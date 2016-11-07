//
//  UserInteraction.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

enum UserInteraction { }

extension UserInteraction {

    struct BoardViewDelegate: BoardViewDelegateType {

        weak var game: Game?

        var pieceNodeDataSource: PieceNodeDataSource
        var squareNodeDataSource: SquareNodeDataSource
        var arrowNodeDataSource: ArrowNodeDataSource

        weak var presentingViewController: ViewController?

        var _availableTargetsCache: [Square] = []
        var _availableCapturesCache: [Square] = []
        
    }

    struct HistoryViewDelegate: HistoryViewDelegateType {

        weak var game: Game?

    }

    struct GameDelegate: GameDelegateType {

        var traversalHandler: Game.TraversalHandler
        
    }

}

