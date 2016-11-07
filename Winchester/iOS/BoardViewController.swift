//
//  BoardViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class BoardViewController: UIViewController, BoardViewControllerType {

    fileprivate var tapGesture: UITapGestureRecognizer!
    fileprivate var panGesture: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTap))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDidPan))
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
    }

    public private(set) var currentOrientation: BoardView.Orientation = .bottom
    func rotateView() {
        self.currentOrientation.rotate()
        UIView.animate(withDuration: 0.3) {
            self.view.transform = self.view.transform.rotated(by: .pi * -0.5)
        }
    }

    // MARK: - BoardViewControllerType Protocol

    var boardViewDelegate: BoardViewDelegate?
    var boardViewDataSource: BoardViewDataSource?
    var piecesDataSource: PieceNodeDataSource?

    var _interactionState: BoardView.InteractionState = .normal
    var _initialSquare: Square?
    weak var _activeNode: Piece.Node?

}

extension BoardViewController {

    func userDidTap(_ gesture: UITapGestureRecognizer) {
        if let square = view.square(for: gesture.location(in: view)) {
            switch panGesture.isEnabled {
            case true:
                userDidSelect(on: square)
                panGesture.isEnabled = false
            case false:
                userDidRelease(on: square)
                panGesture.isEnabled = true
            }
        }
    }

    func userDidPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        guard let square = view.square(for: location) else {
            userDidRelease(on: nil)
            return
        }
        switch gesture.state {
        case .began:
            tapGesture.isEnabled = false
            userDidSelect(on: square)
        case .changed:
            userDidMove(to: square, at: location)
        case .ended, .failed, .cancelled:
            userDidRelease(on: square)
            tapGesture.isEnabled = true
        case .possible:
            return
        }
    }

}
