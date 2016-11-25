//
//  Shims.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

#if os(OSX)
    import Cocoa
    public typealias ViewController = NSViewController
    public typealias CollectionViewController = NSCollectionViewController
    public typealias CollectionView = NSCollectionView
    public typealias CollectionViewCell = NSCollectionViewCell
    public typealias View = NSView
//    public typealias Storyboard = NSStoryboard
#elseif os(iOS) || os(tvOS)
    import UIKit
    public typealias ViewController = UIViewController
    public typealias CollectionViewController = UICollectionViewController
    public typealias CollectionView = UICollectionView
    public typealias CollectionViewCell = UICollectionViewCell
    public typealias View = UIView
#endif

public protocol ViewControllerType: class {
    var view: View! { get }
}

