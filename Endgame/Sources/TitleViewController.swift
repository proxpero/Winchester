//
//  TitleViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

internal final class TitleViewContoller: ViewController {

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    var model: (white: Player?, black: Player?, outcome: Outcome)

    init(white: Player, black: Player, outcome: Outcome) {
        model = (white, black, outcome)
        super.init(nibName: "TitleViewController", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        model = (nil, nil, Outcome.undetermined)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.heightAnchor.constraint(equalToConstant: 44)
        white.text = model.white?.name
        black.text = model.black?.name
        outcome.text = model.outcome.userDescription
    }
}
