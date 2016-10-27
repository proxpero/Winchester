//
//  Geometry.swift
//  Endgame
//
//  Created by Todd Olsen on 8/14/16.
//
//

import CoreGraphics

extension CGSize {

    var square: CGSize {
        let edge = self.width / 8.0
        return CGSize(width: edge, height: edge)
    }

}

