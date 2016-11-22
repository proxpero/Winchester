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

extension CollectionView {
    public func dequeue<Cell: CollectionViewCell>(_ cellType: Cell.Type, at indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: "\(cellType.self)", for: indexPath) as? Cell else { fatalError("Could not dequeue a cell of type: \(Cell.self)") }
        return cell
    }
}
