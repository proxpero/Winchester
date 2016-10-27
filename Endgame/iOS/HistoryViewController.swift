//
//  HistoryViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

let height: CGFloat = 44.0

#if os(OSX)
    import Cocoa
    typealias CollectionViewController = NSCollectionViewController
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias CollectionViewController = UICollectionViewController
#endif

final class HistoryViewController: CollectionViewController {

    var model: HistoryViewDataSource!
    var delegate: HistoryViewDelegate?

}

#if os(iOS) || os(tvOS)

// MARK: - External Actions

extension HistoryViewController {

    override func viewDidLoad() {
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func handleSwipe(recognizer: UISwipeGestureRecognizer) {

        guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else { return }

        let isLeft = recognizer.direction == UISwipeGestureRecognizerDirection.left
        let isRight = recognizer.direction == UISwipeGestureRecognizerDirection.right
        guard isLeft || isRight else { return }

        let candidate = isLeft ? model.nextMoveCell(after: indexPath) : model.previousMoveCell(before: indexPath)
        guard model.isValidSelection(for: candidate) else { return }

        collectionView?.selectItem(at: candidate, animated: true, scrollPosition: .centeredHorizontally)
        delegate?.userDidSelectHistoryItem(at: model.itemIndex(for: candidate))

    }
}

// MARK: - UIKit

extension HistoryViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.cellCount()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HistoryCell.self)", for: indexPath) as? HistoryCell else { fatalError() }
        model.itemType(at: indexPath).configureCell(cell: cell)
        return cell
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return model.itemType(at: indexPath).shouldBeSelected
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.userDidSelectHistoryItem(at: model.itemIndex(for: indexPath))
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: model.itemType(at: indexPath).width, height: height)
    }

}

#endif

