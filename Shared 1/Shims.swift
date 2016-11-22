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

protocol ViewControllerType: class {
    var view: View! { get }
}

protocol Storyboard {
    init(name: String, bundle: Bundle?)
    func instantiateViewController(withIdentifier: String) -> ViewController
    static func main() -> Storyboard
    func instantiate<A: ViewController>(_ type: A.Type) -> A
}

extension Storyboard {
    static func main() -> Storyboard {
        let storyboard = Self.init(name: "Main", bundle: nil)
        return storyboard
    }

    func instantiate<A: ViewController>(_ type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }

}

extension CollectionView {
    func dequeue<A: CollectionViewCell>(_ cellType: A.Type, at indexPath: IndexPath) -> A {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: "\(cellType.self)", for: indexPath) as? A else { fatalError("Could not dequeue a cell of type: \(A.self)") }
        return cell
    }
}
