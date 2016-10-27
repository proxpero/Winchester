//
//  UISwipeGestureRecognizer+Extensions.swift
//  Endgame
//
//  Created by Todd Olsen on 9/7/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

extension UISwipeGestureRecognizer {
    public convenience init(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection) {
        self.init(target: target, action: action)
        self.direction = direction
    }
}

extension UIView {
    public func addSwipeGestureRecognizer(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection = .right ) {
        let swipe = UISwipeGestureRecognizer(target: target, action: action, direction: direction)
        addGestureRecognizer(swipe)
    }
}
