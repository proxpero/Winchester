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

    @IBOutlet var newGameButton: UIButton!

    weak var delegate: NewGameViewControllerDelegate?

    var opponentName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let title: String

        if let opponentName = opponentName {
            title = "Play a new game against \(opponentName)"
        } else {
            title = "Play a new game"
        }

        newGameButton.setTitle(title, for: .normal)

    }

    @IBAction func newGameAction(_ sender: UIButton) {
        delegate?.didSelectNewGame()
    }

}

protocol NewGameViewControllerDelegate: class {
    func didSelectNewGame()
}
