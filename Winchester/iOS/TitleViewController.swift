//
//  TitleViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

internal final class TitleViewController: UIViewController {

    var model: TitleViewDataSource? {
        didSet { reloadData() }
    }

    func reloadData() {
        guard let model = model, view != nil else { return }
        white.text = model.white.name
        black.text = model.black.name
    }

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    override func viewDidLoad() {
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
