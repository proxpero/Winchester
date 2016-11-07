//
//  TitleViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

internal final class TitleViewController: UIViewController, TitleViewControllerType {

    var dataSource: TitleViewDataSource? {
        didSet { reloadData() }
    }

    func reloadData() {
        guard let dataSource = dataSource, view != nil else { return }
        white.text = dataSource.white.name
        black.text = dataSource.black.name
    }

    @IBOutlet var white: UILabel!
    @IBOutlet var black: UILabel!
    @IBOutlet var outcome: UILabel!

    override func viewDidLoad() {
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
