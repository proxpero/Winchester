//
//  BoardViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Endgame
import Shared

final class BoardViewController: ViewController, BoardViewControllerType {

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

