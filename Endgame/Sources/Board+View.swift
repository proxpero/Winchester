//
//  Board+View.swift
//  Endgame
//
//  Created by Todd Olsen on 8/5/16.
//
//

#if os(OSX)
    import Cocoa
//    typealias TKOColor = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
//    typealias TKOColor = UIColor
#endif

#if os(OSX) || os(iOS) || os(tvOS)

extension Board.Space {

    internal func _view(size: CGFloat) -> ChessView {
        #if os(OSX)
            let rectY = CGFloat(rank.index) * size
        #else
            let rectY = CGFloat(7 - rank.index) * size
        #endif
        let frame = CGRect(x: CGFloat(file.index) * size,
                           y: rectY,
                           width: size,
                           height: size)
        var textFrame = CGRect(x: 0, y: 0, width: size, height: size)
        let fontSize = size * 0.625
        let view = ChessView(frame: frame)
        let pieceString = piece.map({ String($0.specialCharacter(background: color)) }) ?? ""

        let white = ChessColor.white
        let black = ChessColor.black

        let backgroundColor: ChessColor = color.isWhite ? white : black
        let textColor: ChessColor = color.isWhite ? black : white
        #if os(OSX)
            view.wantsLayer = true
            let text = NSText(frame: textFrame)
            view.layer?.backgroundColor = backgroundColor.cgColor
            text.alignment = .center
            text.font = .systemFont(ofSize: fontSize)
            text.isEditable = false
            text.isSelectable = false

            text.string = pieceString
            text.drawsBackground = false
            text.textColor = textColor
            view.addSubview(text)
        #else
            view.backgroundColor = backgroundColor
            let label = UILabel(frame: textFrame)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: fontSize)
            label.text = pieceString
            label.textColor = textColor
            view.addSubview(label)
        #endif
        return view
    }

}

extension Board {

    public func view(edge: CGFloat) -> ChessView {

        let view = ChessView(frame: CGRect(x: 0, y: 0, width: edge, height: edge))
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
        let view = ChessView(frame: frame)
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

#endif

