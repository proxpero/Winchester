//
//  HistoryViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit
import Shared

let height: CGFloat = 44.0

import UIKit

public final class HistoryViewController: UICollectionViewController, HistoryViewControllerType {

    weak public var delegate: HistoryViewDelegate?
    weak public var dataSource: HistoryViewDataSource?

}

extension HistoryViewController {

    override public func viewDidLoad() {
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        collectionView?.collectionViewLayout = layout
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

extension HistoryViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource

    private var _dataSource: HistoryViewDataSource {
        guard let dataSource = dataSource else { fatalError("Expected a dataSource") }
        return dataSource
    }

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _dataSource.cellCount()
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: HistoryCell.self, at: indexPath)
        _dataSource.itemType(at: indexPath).configureCell(cell: cell)
        return cell
    }

    // MARK: - UICollectionViewDelegate

    override public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return _dataSource.itemType(at: indexPath).shouldBeSelected
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let itemIndex = _dataSource.itemIndex(for: indexPath)
        delegate?.userDidSelectHistoryItem(at: itemIndex)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _dataSource.itemType(at: indexPath).width, height: height)
    }

}

final class HistoryCell: UICollectionViewCell, HistoryCellType {

    @IBOutlet var label: UILabel!
    var isBordered: Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isBordered { return }
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 3, dy: 6), cornerRadius: 6)
        UIColor(rgb: 0x4A4A50).set()
        path.stroke()
        (isSelected ? UIColor(rgb: 0x4A4A50) : UIColor.clear).set()
        path.fill()
    }

    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
            label.textColor = isSelected ? UIColor.white : UIColor(rgb: 0x4A4A50)
        }
    }

    func setText(text: String) {
        self.label.text = text
    }

    func setIsBordered(isBordered: Bool) {
        self.isBordered = isBordered
    }

    func setTextAlignment(textAlignment: NSTextAlignment) {
        label.textAlignment = textAlignment
    }

}

