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
//    public typealias CollectionViewController = NSCollectionViewController
//    public typealias CollectionView = NSCollectionView
//    public typealias CollectionViewCell = NSCollectionViewCell
#elseif os(iOS) || os(tvOS)
    import UIKit
//    public typealias CollectionViewController = UICollectionViewController
//    public typealias CollectionView = UICollectionView
//    public typealias CollectionViewCell = UICollectionViewCell
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

final class HistoryViewController: CollectionViewController, HistoryViewControllerType {

    var dataSource: History.DataSource!
    var delegate: History.Delegate!

}

#if os(iOS) || os(tvOS)

    extension HistoryViewController {

        override func viewDidLoad() {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {

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
            return dataSource.cellCount()
        }

        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeue(HistoryCell.self, at: indexPath)
            dataSource.itemType(at: indexPath).configureCell(cell: cell)
            return cell
        }

        // MARK: - UICollectionViewDelegate

        override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            return dataSource.itemType(at: indexPath).shouldBeSelected
        }

        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            delegate?.userDidSelectHistoryItem(at: dataSource.itemIndex(for: indexPath))
        }

        // MARK: - UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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


