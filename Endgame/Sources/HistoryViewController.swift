//
//  HistoryViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import SpriteKit

internal final class HistoryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var moveSelectionHandler: (Int) -> () = { _ in }

    var game: Game? // {
//        didSet {
//            guard let game = game else { return }
//            let moves = game.history.count + game.undoHistory.count
//            rows = 1 + moves + (moves % 2 == 0 ? moves/2 : (moves + 1)/2)
//        }
//    }

    var rows: Int {
        guard let game = game else {
            return 0
        }
        let moves = game.history.count + game.undoHistory.count
        let rows = 1 + moves + (moves % 2 == 0 ? moves/2 : (moves + 1)/2)
        return rows
    }

    override func viewDidAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    func advanceMove(sender: UISwipeGestureRecognizer) {
        guard
            let indexPath = collectionView?.indexPathsForSelectedItems?.first,
            indexPath.row < rows - 1
        else { return }
        collectionView?.selectItem(at: IndexPath(row: indexPath.row.nextMoveIndex(), section: 0), animated: true, scrollPosition: .centeredHorizontally)
        moveSelectionHandler(indexPath.row.moveIndex() + 1)
    }

    func reverseMove(sender: UISwipeGestureRecognizer) {
        guard
            let indexPath = collectionView?.indexPathsForSelectedItems?.first,
            indexPath.row > 1
        else { return }
        collectionView?.selectItem(at: IndexPath(row: indexPath.row.previousMoveIndex(), section: 0), animated: true, scrollPosition: .centeredHorizontally)
        moveSelectionHandler(indexPath.row.moveIndex() - 1)
    }

    private func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> HistoryCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else { fatalError() }
        return cell
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let game = game else { return 0 }
        return 1 + rows
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else { fatalError() }
        HistoryCell.CellType(row: indexPath.row, game: game).configureCell(cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return HistoryCell.CellType(row: indexPath.row, game: game).size
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return HistoryCell.CellType(row: indexPath.row, game: game).isBordered
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        moveSelectionHandler(indexPath.row.moveIndex())
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

    enum CellType: CustomStringConvertible {

        case start
        case number(Int)
        case move(String)

        init(row: Int, game: Game?) {
            if row == 0 { self = .start }
            else if row.isNumberRow() { self = .number(row.numberIndex()) }
            else {
                guard let game = game else { fatalError() }
                let moveIndex = row.moveIndex()
                self = .move(game.history[row.moveIndex()].sanMove)
            }
        }

        var description: String {
            switch self {
            case .start: return "Start"
            case .number(let n): return "\(n)."
            case .move(let m): return m.replacingOccurrences(of: "x", with: "×")
            }
        }

        var size: CGSize {
            let width: CGFloat
            switch self {
            case .start: width = 80
            case .number: width = 45
            case .move: width = 70
            }
            return CGSize(width: width, height: 44)
        }

        var isBordered: Bool {
            switch self {
            case .number: return false
            default: return true
            }
        }
        
        func configureCell(cell: HistoryCell) {
            cell.label.text = self.description
            cell.isBordered = self.isBordered
            cell.label.textAlignment = self.isBordered ? .center : .right
        }

    }

}

extension Int {

    // Returns whether the `self` as an index in the collection view is a `number` cell.
    func isNumberRow() -> Bool {
        return (self-1)%3 == 0
    }

    // Converts a collection view cell index to a natural number index.
    func numberIndex() -> Int {
        return (self-1)/3 + 1
    }

    // Converts a collection view cell index to its index in a `game`'s `moveHistory`.
    func moveIndex() -> Int {
        return 2*(self)/3 - 1
    }

    // Returns the next index after `self` of a move in a history collection view.
    func nextMoveIndex() -> Int {
        let next = self + 1
        return next + (next.isNumberRow() ? 1 : 0)
    }

    // Returns the previous index before `self` of a move in a history collection view.
    func previousMoveIndex() -> Int {
        let prev = self - 1
        return prev - (prev.isNumberRow() ? 1 : 0)
    }

}
