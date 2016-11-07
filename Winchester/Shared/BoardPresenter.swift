//
//  BoardPresenter.swift
//  Winchester
//
//  Created by Todd Olsen on 10/28/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import CoreGraphics
import Endgame

protocol BoardPresenter {
    var frame: CGRect { get }
}

extension BoardPresenter {
    func square(for location: CGPoint, isFlipped: Bool = true) -> Square? {
        // divide edge by 8 and parition from origin out.

        let rowWidth = frame.size.width / 8.0

        // Determine which partition of the board (0..<8) the coordinate occupies.
        func partition(for coordinate: CGFloat, upperBound: CGFloat) -> Int {
            var boundry = upperBound
            var partition = 8
            while (coordinate < boundry) && (partition > 0) {
                partition -= 1
                boundry = rowWidth * CGFloat(partition)
            }
            return partition
        }

        let fileIndex = partition(for: location.x, upperBound: frame.origin.x + frame.size.width)
        var rankIndex = partition(for: location.y, upperBound: frame.origin.y + frame.size.height)
        rankIndex = isFlipped ? 7 - rankIndex : rankIndex

        return Square(file: File(index: fileIndex),
                      rank: Rank(index: rankIndex))
    }
}

#if os(OSX)
    import Cocoa
    extension NSView: BoardPresenter { }
#elseif os(iOS) || os(tvOS)
    import UIKit
    extension UIView: BoardPresenter { }
#endif

