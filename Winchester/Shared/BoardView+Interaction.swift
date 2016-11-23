//
//  BoardView+Interaction.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

extension BoardView {

    public enum InteractionState {
        case dormant
        case active(Square)
        case ended(Move)
    }

    public enum Orientation {

        case bottom
        case right
        case top
        case left

        init(angle: CGFloat) {
            let twoPi: CGFloat = 2.0 * .pi
            var ref = angle
            while ref > twoPi {
                ref -= twoPi
            }

            if (0.75 * .pi) > ref && ref >= (0.25 * .pi) {
                self = .right
            } else if (1.25 * .pi) > ref && ref >= (0.75 * .pi) {
                self = .top
            } else if (1.75 * .pi) > ref && ref >= (1.25 * .pi) {
                self = .left
            } else {
                self = .bottom
            }
        }

        static var all: [Orientation] {
            return [.bottom, .right, .top, .left]
        }

        public func angle() -> CGFloat {
            let multiplier: CGFloat
            switch self {
            case .bottom: multiplier = 0.0
            case .right: multiplier = 0.5
            case .top: multiplier = 1.0
            case .left: multiplier = 1.5
            }
            return .pi * -multiplier
        }

        mutating func rotate() {
            switch self {
            case .bottom: self = .right
            case .right: self = .top
            case .top: self = .left
            case .left: self = .bottom
            }
        }
        
    }
    
}
