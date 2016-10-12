//
//  HistoryViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

final class HistoryCoordinator {

    let cellType: (Game) -> (Int) -> HistoryCellType
    let rows: (Game) -> () -> Int
    let update: (UICollectionView) -> () -> ()

    init() {

        self.cellType = { game in
            { index in
                HistoryCellType(row: index, game: game)
            }
        }

        self.rows = { game in
            return {
                let moves = game.count
                let rows = 1 + moves + (moves % 2 == 0 ? moves/2 : (moves + 1)/2) + 1
                return rows
            }
        }

        self.update = { collectionView in
            return {
                collectionView.reloadData()
                let row = collectionView.numberOfItems(inSection: 0) - 2
                let indexPath = IndexPath(row: row, section: 0)
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .centeredHorizontally
                )
            }
        }

    }
 
}

internal extension Game {

    var historyRows: Int {
        let moves = self.count
        let rows = 1 + moves + (moves % 2 == 0 ? moves/2 : (moves + 1)/2) + 1
        return rows
    }

}


internal final class HistoryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var didSelect: (Int?) -> () = { _ in }
    var cellType: (_ row: Int) -> HistoryCellType = { _ in return .start }
    var rows: () -> Int = { _ in 0 }

    func cellType(for game: Game) -> (Int) -> HistoryCellType {
        return { index in
            HistoryCellType(row: index, game: game)
        }
    }

    func advanceMove(sender: UISwipeGestureRecognizer) {
        
        guard
            let indexPath = collectionView?.indexPathsForSelectedItems?.first,
            indexPath.row < rows()
        else { return }

        collectionView?.selectItem(
            at: IndexPath(row: indexPath.row.asNextMoveRowIndex, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally)
        let selectedIndex: Int? = indexPath.row > 0 ? indexPath.row.asItemIndex! + 1 : 0
        // check if too far
        didSelect(selectedIndex)
    }

    func handleSwipe(recognizer: UISwipeGestureRecognizer) {

        guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else {
            return
        }

        let selectedRow: Int
        let add: Bool
        
        if recognizer.direction == UISwipeGestureRecognizerDirection.left && indexPath.row < rows() - 1 {
            selectedRow = indexPath.row.asNextMoveRowIndex
            // Don't allow selection past the end
            if selectedRow == rows() - 1 { return }
            add = true
        } else if recognizer.direction == UISwipeGestureRecognizerDirection.right && indexPath.row > 1 {
            selectedRow = indexPath.row.asPreviousMoveRowIndex
            add = false
        } else {
            return
        }

        collectionView?.selectItem(
            at: IndexPath(row: selectedRow, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )

        var selectedIndex: Int?

        switch (selectedRow.asItemIndex, add) {
        case (.none, true):
            selectedIndex = 0
        case (.none, false):
            selectedIndex = nil
        case (.some(let index), true):
            selectedIndex = index
        case (.some(let index), false):
            selectedIndex = index
        }
        didSelect(selectedIndex)
    }

    // MARK: - UIKit

    override func viewDidAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HistoryCell.self)", for: indexPath) as? HistoryCell else { fatalError() }
        cellType(indexPath.row).configureCell(cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellType(indexPath.row).size
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return cellType(indexPath.row).shouldBeSelected
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        didSelect(indexPath.row.asItemIndex)
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

enum HistoryCellType: CustomStringConvertible, Equatable {

    case start
    case number(Int)
    case move(String)
    case outcome(Outcome)

    init(row: Int, game: Game) {

        guard let itemIndex = row.asItemIndex else {
            self = .start
            return
        }

        // If white plays the last move or if black plays the last move...
        if itemIndex >= game.endIndex || (row.isNumberRow && itemIndex == game.endIndex - 1) {
            self = .outcome(game.outcome)
        }
        else if row.isNumberRow {
            self = .number(row.asFullmoveIndex)
        }
        else {
            self = .move(game[itemIndex].sanMove)
        }
    }

    var description: String {
        switch self {
        case .start: return "Start"
        case .number(let n): return "\(n)."
        case .move(let m): return m.replacingOccurrences(of: "x", with: "×")
        case .outcome(let outcome): return outcome.userDescription
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
        return CGSize(width: width, height: 44)
    }

    var isBordered: Bool {
        switch self {
        case .number: return false
        case .outcome: return false
        default: return true
        }
    }

    func configureCell(cell: HistoryCell) {
        cell.label.text = self.description
        cell.isBordered = self.isBordered
        let alignment: NSTextAlignment
        switch self {
        case .start: alignment = .center
        case .number: alignment = .right
        case .move: alignment = .center
        case .outcome: alignment = .center
        }
        cell.label.textAlignment = alignment
    }

    static func == (lhs: HistoryCellType, rhs: HistoryCellType) -> Bool {
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

extension Int {

    var isEven: Bool {
        return self % 2 == 0
    }

    /// Returns whether `self` as an row index in the collection view is a `number` cell.
    var isNumberRow: Bool {
       return (self-1)%3 == 0
    }

    /// Converts the index from a game's history array to its corresponding row index in the collection view.
    var asRowIndex: Int {
        return ((self.isEven ? 2 : 0) + (6 * (self + 1))) / 4
    }

    /// Converts a collection view cell index to a natural number index. For example,
    /// in the sequence "e4 e5 Nc3 Nf6 d3", the 
    var asFullmoveIndex: Int {
        return (self-1)/3 + 1
    }

    /// Converts a collection view cell index to its index in a `game`'s `moveHistory`.
    var asItemIndex: Int? {
        guard self != 0 else {
            return nil
        }
        return 2*self/3 - 1
    }

    /// Returns the next index after `self` of a move in a history collection view.
    var asNextMoveRowIndex: Int {
        let next = self + 1
        return next + (next.isNumberRow ? 1 : 0)
    }

    /// Returns the previous index before `self` of a move in a history collection view.
    var asPreviousMoveRowIndex: Int {
        let prev = self - 1
        return prev - (prev.isNumberRow ? 1 : 0)
    }

}
