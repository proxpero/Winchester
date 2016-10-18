//
//  TitleViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

internal final class TitleViewContoller: UIViewController {

    struct Model {
        let white: Player
        let black: Player
        let outcome: Outcome
        init(for game: Game) {
            self.white = game.whitePlayer
            self.black = game.blackPlayer
            self.outcome = game.outcome
        }
    }

    var model: Model? {
        didSet {
            refresh()
        }
    }

    func refresh() {
        guard let model = model else { return }
        white.text = model.white.name
        black.text = model.black.name
        outcome.text = model.outcome.userDescription
    }

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.heightAnchor.constraint(equalToConstant: 44)
        refresh()
    }
}
