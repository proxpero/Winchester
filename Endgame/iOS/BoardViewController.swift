//
//  BoardViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

final class BoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
    }

}

