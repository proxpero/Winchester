//
//  TitleViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

internal final class TitleViewContoller: UIViewController {

    var dataSource: TitleViewDataSource? {
        didSet { reloadData() }
    }

    func reloadData() {
        guard let dataSource = dataSource, view != nil else { return }
        white.text = dataSource.white.name
        black.text = dataSource.black.name
        outcome.text = dataSource.outcome.userDescription
    }

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    override func viewDidLoad() {
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
