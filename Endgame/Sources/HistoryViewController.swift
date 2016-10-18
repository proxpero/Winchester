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

    var model: Model!
    var delegate: Delegate!

}

// MARK: - ItemType

extension HistoryViewController {

    enum ItemType {

        case start
        case number(Int)
        case move(String)
        case outcome(Outcome)

        var text: String {
            switch self {
            case .start: return "Start"
            case .number(let n): return "\(n)."
            case .move(let m): return m.replacingOccurrences(of: "x", with: "×")
            case .outcome(let outcome): return outcome.userDescription
            }
        }

        var textAlignment: NSTextAlignment {
            switch self {
            case .start: return .center
            case .number: return .right
            case .move: return .center
            case .outcome: return .center
            }
        }

        var shouldBeSelected: Bool {
            switch self {
            case .start: return true
            case .number: return false
            case .move: return true
            case .outcome: return false
            }
        }

        var size: CGSize {
            let width: CGFloat
            switch self {
            case .start: width = 80
            case .number: width = 45
            case .move: width = 70
            case .outcome: width = 80
            }
            return CGSize(width: width, height: height)
        }

        var isBordered: Bool {
            switch self {
            case .number: return false
            case .outcome: return false
            default: return true
            }
        }

        func configureCell(cell: HistoryCell) {
            cell.label.text = self.text
            cell.isBordered = self.isBordered
            cell.label.textAlignment = self.textAlignment
        }

        static func == (lhs: ItemType, rhs: ItemType) -> Bool {
            switch (lhs, rhs) {
            case (.start, .start): return true
            case (.number(let a), .number(let b)): return a == b
            case (.move(let a), .move(let b)): return a == b
            case (.outcome(let a), .outcome(let b)): return a == b
            default:
                return false
            }
        }
    }
}

// MARK: Model

extension HistoryViewController {

    struct Model {

        let rowCount: () -> (Int)
        private let outcome: () -> Outcome
        private let sanMove: (Int) -> String

        init(for game: Game) {
            self.rowCount = {
                let moves = game.count
                let rows = 1 + moves + (moves.isEven ? moves/2 : (moves + 1)/2) + 1
                return rows
            }
            self.outcome = {
                return game.outcome
            }
            self.sanMove = { index in
                return game[index].sanMove
            }
        }

        func itemType(at indexPath: IndexPath) -> ItemType {

            if isStart(for: indexPath) { return .start }
            if isOutcome(for: indexPath) { return .outcome(self.outcome()) }
            if isNumberCell(for: indexPath) { return .number(fullmoveValue(for: indexPath)) }

            guard let itemIndex = itemIndex(for: indexPath) else { fatalError("Expected a move") }
            return .move(self.sanMove(itemIndex))

        }

        func itemIndex(for indexPath: IndexPath) -> Int? {
            let row = indexPath.row
            guard row != 0 else {
                return nil
            }
            return 2*row/3 - 1
        }

        func isStart(for indexPath: IndexPath) -> Bool {
            return indexPath.row == 0
        }

        func isOutcome(for indexPath: IndexPath) -> Bool {
            return indexPath.row == rowCount() - 1
        }

        func isNumberCell(for indexPath: IndexPath) -> Bool {
            return (indexPath.row-1)%3 == 0
        }

        func indexPath(for itemIndex: Int) -> IndexPath {
            let row = ((itemIndex.isEven ? 2 : 0) + (6 * (itemIndex + 1))) / 4
            return IndexPath(row: row, section: 0)
        }

        func fullmoveValue(for indexPath: IndexPath) -> Int {
            return (indexPath.row-1)/3 + 1
        }

        func nextMoveCell(after indexPath: IndexPath) -> IndexPath {
            let next = indexPath.row + 1
            let candidate = IndexPath(row: next, section: 0)
            if isNumberCell(for: candidate) {
                return IndexPath(row: next+1, section: 0)
            } else {
                return candidate
            }
        }

        func previousMoveCell(before indexPath: IndexPath) -> IndexPath {
            let prev = indexPath.row - 1
            let candidate = IndexPath(row: prev, section: 0)
            if isNumberCell(for: candidate) {
                return IndexPath(row: prev-1, section: 0)
            } else {
                return candidate
            }
        }

        var lastMove: IndexPath {
            return IndexPath(row: rowCount() - 1, section: 0)
        }

        func contains(indexPath: IndexPath) -> Bool {
            return (0 ..< rowCount()).contains(indexPath.row)
        }
    }
}

// MARK: - Delegate

extension HistoryViewController {

    struct Delegate {
        let didSelectItem: (Int?) -> ()

        init(didSelectItem: @escaping (Int?) -> ()) {
            self.didSelectItem = didSelectItem
        }

        func didSelectHistoryItem(at index: Int?) {

        }

        func didSelectCell(at indexPath: IndexPath) {
            // a conversion must be made to map the index path to the proper history item index.
            // then call `didSelectHistoryItem(at: index)`
        }

    }
}

#if os(iOS) || os(tvOS)

// MARK: - External Actions

extension HistoryViewController {

    func update() {
        collectionView?.reloadData()
        collectionView?.selectItem(at: model.lastMove, animated: true, scrollPosition: .centeredHorizontally)
    }

    func handleSwipe(recognizer: UISwipeGestureRecognizer) {

        guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else { return }

        let isLeft = recognizer.direction == UISwipeGestureRecognizerDirection.left
        let isRight = recognizer.direction == UISwipeGestureRecognizerDirection.right
        guard isLeft || isRight else { return }

        let candidate = isLeft ? model.nextMoveCell(after: indexPath) : model.previousMoveCell(before: indexPath)
        guard model.contains(indexPath: candidate) else { return }

        collectionView?.selectItem(at: candidate, animated: true, scrollPosition: .centeredHorizontally)
        delegate.didSelectCell(at: candidate)

    }

}

// MARK: - UIKit

extension HistoryViewController: UICollectionViewDelegateFlowLayout {

    override func viewDidAppear(_ animated: Bool) {
        // handle the initial selection?
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.rowCount()
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
        delegate.didSelectCell(at: indexPath)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return model.itemType(at: indexPath).size
    }

}

final class HistoryCell: UICollectionViewCell {

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

extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
}
