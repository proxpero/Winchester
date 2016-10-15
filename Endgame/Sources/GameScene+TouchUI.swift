//
//  GameScene+TouchUI.swift
//  Endgame
//
//  Created by Todd Olsen on 9/7/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

extension GameScene {

    func tapAction(sender: UITapGestureRecognizer) {
        if
            let location = view?.convert(sender.location(in: view), to: self),
            let square = self.square(at: location)
        {
            userDidSelect(square)
        }
    }

    func panAction(sender: UIPanGestureRecognizer) {
        if let location = view?.convert(sender.location(in: view), to: self) {
            let square = self.square(at: location)
            

        }
    }
}
