//
//  Board+View.swift
//  Endgame
//
//  Created by Todd Olsen on 8/5/16.
//
//

import UIKit

extension Board.Space {

    internal func _view(size: CGFloat) -> UIView {
//        #if os(OSX)
//            let rectY = CGFloat(rank.index) * size
//        #else
            let rectY = CGFloat(7 - rank.index) * size
//        #endif
        let frame = CGRect(x: CGFloat(file.index) * size,
                           y: rectY,
                           width: size,
                           height: size)
        let textFrame = CGRect(x: 0, y: 0, width: size, height: size)
        let fontSize = size * 0.625
        let view = UIView(frame: frame)
        let str = piece.map({ String($0.specialCharacter(background: color)) }) ?? ""

        let white = UIColor.white
        let black = UIColor.black

//        #if os(OSX)
//            view.wantsLayer = true
//            let text = NSText(frame: textFrame)
//            view.layer?.backgroundColor = bg.cgColor
//            text.alignment = .center
//            text.font = .systemFont(ofSize: fontSize)
//            text.isEditable = false
//            text.isSelectable = false
//
//            text.string = str
//            text.drawsBackground = false
//            text.textColor = tc
//            view.addSubview(text)
//        #else
            view.backgroundColor = color.isWhite ? white : black
            let label = UILabel(frame: textFrame)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: fontSize)
            label.text = str
            label.textColor = color.isWhite ? black : white
            view.addSubview(label)
//        #endif
        return view
    }

}

extension Board {

    public func view(edge: CGFloat) -> UIView {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: edge, height: edge))
        let spaceEdge = edge / 8.0
        for space in self {
            view.addSubview(space._view(size: spaceEdge))
        }
        return view
    }

    /// Returns the `PlaygroundQuickLook` for `self`.
    private var _customPlaygroundQuickLook: PlaygroundQuickLook {
        let spaceSize: CGFloat = 80
        let boardSize = spaceSize * 8
        let frame = CGRect(x: 0, y: 0, width: boardSize, height: boardSize)
        let view = UIView(frame: frame)
        for space in self {
            view.addSubview(space._view(size: spaceSize))
        }
        return .view(view)
    }

    /// A custom playground quick look for this instance.
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return _customPlaygroundQuickLook
    }
    
}


