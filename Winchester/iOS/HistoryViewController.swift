//
//  HistoryViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

let height: CGFloat = 44.0

#if os(OSX)
    import Cocoa
    public typealias CollectionViewController = NSCollectionViewController
    public typealias CollectionView = NSCollectionView
    public typealias CollectionViewCell = NSCollectionViewCell
#elseif os(iOS) || os(tvOS)
    import UIKit
    public typealias CollectionViewController = UICollectionViewController
    public typealias CollectionView = UICollectionView
    public typealias CollectionViewCell = UICollectionViewCell
#endif

/*
final class HistoryViewController: CollectionViewController, GameDelegate {

    var model: HistoryViewModel!
    var delegate: HistoryViewDelegate?

    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        collectionView?.reloadData()
        collectionView?.selectItem(at: model.lastMove(), animated: true, scrollPosition: .centeredHorizontally)
    }

    func game(_ game: Game, didAdvance items: [HistoryItem]) { }
    func game(_ game: Game, didReverse items: [HistoryItem]) { }
}
*/


