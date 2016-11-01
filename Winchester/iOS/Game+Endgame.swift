//
//  Game+Winchester.swift
//  Winchester
//
//  Created by Todd Olsen on 10/15/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import UIKit

extension UIView {

    func image() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}

extension Game {

    func images(with edge: CGFloat) -> [UIImage] {
        return self.map { $0.position.thumbnail(edge: edge) }.map { $0.image() }
    }

}

extension Outcome {
    func description(for color: Color) -> String {
        switch self {
        case .win(let winner): return winner == color ? "1" : "0"
        case .draw: return "½"
        default: return ""
        }
    }
}