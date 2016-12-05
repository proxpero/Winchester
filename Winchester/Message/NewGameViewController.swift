//
//  NewGameViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 12/2/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Messages
import Endgame
import Shared_iOS

class NewGameViewController: UIViewController {

    weak var delegate: NewGameViewControllerDelegate?

    @IBAction func newGameAction(_ sender: UIButton) {
        delegate?.didSelectNewGame()
    }

}

protocol NewGameViewControllerDelegate: class {
    func didSelectNewGame()
}
