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

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    var model: (white: String?, black: String?, outcome: String) = (nil, nil, "vs")

    init(white: String, black: String, outcome: Game.Outcome?) {
        super.init(nibName: "TitleViewController", bundle: nil)
        model = (white, black, outcome?.description ?? "vs")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.heightAnchor.constraint(equalToConstant: 44)
        white.text = model.white
        black.text = model.black
        outcome.text = model.outcome
    }
}
