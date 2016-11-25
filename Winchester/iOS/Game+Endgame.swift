//
//  Game+Winchester.swift
//  Winchester
//
//  Created by Todd Olsen on 10/15/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import UIKit
import Shared_iOS

extension Game {

    func images(with edge: CGFloat) -> [UIImage] {
        return self.map { $0.position.thumbnail(edge: edge) }.map { UIImage(view: $0)! }
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
