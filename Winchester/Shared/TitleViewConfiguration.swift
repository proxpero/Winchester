//
//  TitleViewDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

protocol TitleViewControllerType: class {

    var dataSource: TitleViewDataSource? { get set }

}

protocol TitleViewDataSource {

    var white: Player { get }
    var black: Player { get }
    var outcome: Outcome { get }

}

enum Title { }

extension Title {

    struct Coordinator {

        private let dataSource: DataSource

        init(game: Game) {
            self.dataSource = DataSource(for: game)
        }

        func configure(_ viewController: TitleViewControllerType) {
            viewController.dataSource = dataSource
        }

    }

    struct DataSource: TitleViewDataSource {

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

//    struct Delegate: 
}

