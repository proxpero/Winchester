//
//  GameCell.swift
//  Winchester
//
//  Created by Todd Olsen on 11/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class GameCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!

    weak var representedGame: Game? {
        didSet {
            guard let game = representedGame, let edge = imageView?.frame.size.width else {
                return
            }
            imageView.image = UIImage(view: game[game.endIndex-1].position.board.view(edge: edge))
        }
    }

}

