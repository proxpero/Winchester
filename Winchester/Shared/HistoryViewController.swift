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
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

/*

 History needs to be informed when a user executes a move so that it can appear promptly in the history view controller.
 */

final class HistoryViewController: CollectionViewController, HistoryViewControllerType {

    var delegate: HistoryViewDelegate?
    var dataSource: HistoryViewDataSource?

}

#if os(iOS) || os(tvOS)

    extension HistoryViewController {

        override func viewDidLoad() {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {

            guard let dataSource = dataSource else {
                return
            }
            guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else { return }

            let isLeft = recognizer.direction == UISwipeGestureRecognizerDirection.left
            let isRight = recognizer.direction == UISwipeGestureRecognizerDirection.right
            guard isLeft || isRight else { return }

            let candidate = isLeft ? dataSource.nextMoveCell(after: indexPath) : dataSource.previousMoveCell(before: indexPath)
            guard dataSource.isValidSelection(for: candidate) else { return }

            collectionView?.selectItem(at: candidate, animated: true, scrollPosition: .centeredHorizontally)
            delegate?.userDidSelectHistoryItem(at: dataSource.itemIndex(for: candidate))

        }
    }

    // MARK: - UIKit

    extension HistoryViewController: UICollectionViewDelegateFlowLayout {

        // MARK: - UICollectionViewDataSource

        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
            return dataSource.cellCount()
        }

        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
            let cell = collectionView.dequeue(HistoryCell.self, at: indexPath)
            dataSource.itemType(at: indexPath).configureCell(cell: cell)
            return cell
        }

        // MARK: - UICollectionViewDelegate

        override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
            return dataSource.itemType(at: indexPath).shouldBeSelected
        }

        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            let itemIndex = dataSource.itemIndex(for: indexPath)
            delegate?.userDidSelectHistoryItem(at: itemIndex)
        }

        // MARK: - UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
            return CGSize(width: dataSource.itemType(at: indexPath).width, height: height)
        }

    }

    final class HistoryCell: CollectionViewCell {

        @IBOutlet var label: UILabel!
        var isBordered: Bool = false

        override func draw(_ rect: CGRect) {
            super.draw(rect)
            if !isBordered { return }
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: 3, dy: 6), cornerRadius: 6)
            UIColor.darkText.set()
            path.stroke()
            (isSelected ? UIColor.darkGray : UIColor.clear).set()
            path.fill()
        }

        override var isSelected: Bool {
            didSet {
                setNeedsDisplay()
                label.textColor = isSelected ? UIColor.white : UIColor.darkText
            }
        }

    }

#endif


