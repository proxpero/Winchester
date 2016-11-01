//
//  BoardScene.swift
//  Winchester
//
//  Created by Todd Olsen on 10/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

final class BoardScene: SKScene {

    // MARK: - Initializers

    override init() {
        super.init(size: CGSize.zero)
        isUserInteractionEnabled = true
        backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal Functions

    func position(for square: Square) -> CGPoint {
        let x = start + offset(for: square.file.index)
        let y = start + offset(for: square.rank.index)
        return CGPoint(x: x, y: y)
    }

    var squareSize: CGSize {
        let rowCount: CGFloat = 8.0
        let edge = (size.width - (squareInset * (rowCount + 1.0))) / rowCount
        return CGSize(width: edge, height: edge)
    }

    // MARK: Private Functions and Properties

    private var squareInset: CGFloat {
        return 1.0
    }

    private var start: CGFloat {
        let boardEdge = size.width
        let squareEdge = squareSize.width
        let start = (-boardEdge + squareEdge) / 2.0
        return start + squareInset
    }

    private func offset(for index: Int) -> CGFloat {
        return CGFloat(index) * (squareSize.width + squareInset)
    }

}

