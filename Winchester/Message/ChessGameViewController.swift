//
//  ChessGameViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 11/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Shared
import Endgame

struct Design: Equatable {

    let isWide: Bool
    let isBiased: Bool
    let showGridLabels: Bool

    init(size: CGSize, isBiased: Bool = false, showGridLabels: Bool = false) {
        self.isWide = size.width > size.height
        self.isBiased = isBiased
        self.showGridLabels = showGridLabels
    }

    var axis: UILayoutConstraintAxis {
        return isWide ? .horizontal : .vertical
    }

    static func == (lhs: Design, rhs: Design) -> Bool {
        return lhs.isWide == rhs.isWide && lhs.isBiased == rhs.isBiased && lhs.showGridLabels == rhs.showGridLabels
    }
    
}

final class GameViewController: UIViewController, GameViewControllerType {
    typealias B = BoardViewController
    typealias H = HistoryViewController

    @IBOutlet var stackView: UIStackView!

    var game: Game?
    weak var delegate: GameViewControllerDelegate?

    var boardViewController: B?
    var historyViewController: H?

    var capturedViewController: CapturedViewController?

    var availableTargetsCache: [Square] = []

    var displayedDesign: Design? = nil

    // Lifecycle

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newDesign = Design(size: view.bounds.size)
        if displayedDesign != newDesign {

            addChildViewController(boardViewController!)
            stackView.addArrangedSubview(boardViewController!.view)
            boardViewController!.didMove(toParentViewController: self)

            addChildViewController(historyViewController!)
            stackView.addArrangedSubview(historyViewController!.view)
            historyViewController!.didMove(toParentViewController: self)

            addChildViewController(capturedViewController!)
            stackView.addArrangedSubview(capturedViewController!.view)
            capturedViewController!.didMove(toParentViewController: self)

            displayedDesign = newDesign
            
        }
    }

    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            guard
                let texture = self.boardViewController?.boardView.boardTexture
                else { fatalError() }
            let image = UIImage(cgImage: texture.cgImage())
            self.delegate?.didExecuteTurn(with: image, gameViewController: self)
        }

    }

}

protocol GameViewControllerDelegate: class {
    func didExecuteTurn(with boardImage: UIImage, gameViewController: GameViewController)
}

final class BoardViewController: UIViewController, BoardViewControllerType  {

    var tapGesture: UITapGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    weak var delegate: BoardViewDelegate?

    var boardView: BoardView {
        guard let boardView = view as? BoardView else {
            fatalError("\(self) requires its view to be a \(BoardView.self)")
        }
        return boardView
    }

    var state: BoardView.InteractionState = .dormant
    var initialSquare: Square? = nil
    weak var activeNode: Piece.Node? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture = UITapGestureRecognizer(target: self, action: .userDidTap)
        panGesture = UIPanGestureRecognizer(target: self, action: .userDidPan)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .userDidTap))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: .userDidPan))

        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        boardView.present()

    }



}

extension BoardViewController {

    func userDidTap(_ gesture: UITapGestureRecognizer) {
        if let square = boardView.square(for: gesture.location(in: view)) {
            switch panGesture.isEnabled {
            case true:
                userDidSelect(square)
                panGesture.isEnabled = false
            case false:
                userDidSelect(square)
                panGesture.isEnabled = true
            }
        }
    }

    func userDidPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        guard let square = boardView.square(for: location) else {
            userDidRelease(on: nil)
            return
        }
        switch gesture.state {
        case .began:
            tapGesture.isEnabled = false
            userDidSelect(square)
        case .changed:
            userDidDragPiece(to: location)
        case .ended, .failed, .cancelled:
            userDidRelease(on: square)
            tapGesture.isEnabled = true
        case .possible:
            return
        }
    }

}

fileprivate extension Selector {
    static let userDidTap = #selector(BoardViewController.userDidTap(_:))
    static let userDidPan = #selector(BoardViewController.userDidPan(_:))
}

final class HistoryViewController: UICollectionViewController, HistoryViewControllerType {

    weak var delegate: HistoryViewDelegate?
    weak var dataSource: HistoryViewDataSource?

}

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

let height: CGFloat = 44.0

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

final class HistoryCell: UICollectionViewCell, HistoryCellType {

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

