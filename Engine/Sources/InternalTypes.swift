//
//  InternalTypes.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

#if os(OSX)
    import Cocoa
    public typealias ChessView = NSView
    public typealias ChessColor = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
    public typealias ChessView = UIView
    public typealias ChessColor = UIColor
#endif

