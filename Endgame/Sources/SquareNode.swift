//
//  SquareNode.swift
//  Endgame
//
//  Created by Todd Olsen on 8/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

#if os(OSX)
    import Cocoa
    typealias TKOColor = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias TKOColor = UIColor
#endif

import SpriteKit
import Engine

final public class SquareNode: SKSpriteNode {

    enum HighlightType {

        case available
        case attacking
        case none

        func texture(for square: Square) -> SKTexture {
            let image: UIImage
            switch self {
            case .available: image = #imageLiteral(resourceName: "AvailableSquare")
            case .attacking: image = #imageLiteral(resourceName: "AttackedSquare")
            case .none:
                switch square.color {
                case .white: image = #imageLiteral(resourceName: "LightSquare")
                case .black: image = #imageLiteral(resourceName: "DarkSquare")
                }
            }
            return SKTexture(image: image)
        }

    }

    let square: Square

    var highlightType: HighlightType {
        didSet {
            self.texture = highlightType.texture(for: square)
        }
    }

    init(square: Square, with size: CGSize) {

        self.square = square
        self.highlightType = HighlightType.none

        super.init(texture: self.highlightType.texture(for: square),
                   color: .clear,
                   size: size)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
