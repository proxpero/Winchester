//
//  Game+Endgame.swift
//  Endgame
//
//  Created by Todd Olsen on 10/15/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import UIKit

extension Game {

    func images(with edge: CGFloat) -> [UIImage] {
        func image(for view: UIView) -> UIImage {
            UIGraphicsBeginImageContext(CGSize(width: edge, height: edge))
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()!

            UIGraphicsEndImageContext()
            return image
        }
        return self.map { $0.position.thumbnail(edge: edge) }.map(image)
    }

}
