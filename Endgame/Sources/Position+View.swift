//
//  Position+View.swift
//  Endgame
//
//  Created by Todd Olsen on 9/24/16.
//
//

#if os(OSX)
    import Cocoa
    extension Position {
        public func thumbnail(edge: CGFloat) -> NSView {
            return board.view(edge: edge)
        }
    }
#elseif os(iOS) || os(tvOS)
    import UIKit
    extension Position {
        public func thumbnail(edge: CGFloat) -> UIView {
            return board.view(edge: edge)
        }
    }
#endif
