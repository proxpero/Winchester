//
//  BoardScene+Touch.swift
//  Winchester
//
//  Created by Todd Olsen on 10/26/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

// MARK: - UIKit

extension BoardScene {

    func tapAction(sender: UITapGestureRecognizer) {
        if
            let location = view?.convert(sender.location(in: view), to: self),
            let square = square(at: location)
        {
            boardDelegate?.userDidTap(on: square)
        }
    }

    func panAction(sender: UIPanGestureRecognizer) {
        if let location = view?.convert(sender.location(in: view), to: self) {
            boardDelegate?.userDidPan(to: square(at: location))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        boardDelegate?.userDidCancelSelection()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let location = view?.convert(touch.location(in: view), to: self), let square = square(at: location)
            else { return }
        boardDelegate?.userDidTap(on: square)
    }
    
    
    
}
