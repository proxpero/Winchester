//
//  BoardViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

enum BoardOrientation {

    case bottom
    case right
    case top
    case left

    init(angle: CGFloat) {

        var ref = angle
        while ref > 2.0 * .pi {
            ref -= 2.0 * .pi
        }

        if (0.75 * .pi) > ref && ref >= (0.25 * .pi) {
            self = .right
        } else if (1.25 * .pi) > ref && ref >= (0.75 * .pi) {
            self = .top
        } else if (1.75 * .pi) > ref && ref >= (1.25 * .pi) {
            self = .left
        } else {
            self = .bottom
        }
    }

    static var all: [BoardOrientation] {
        return [.bottom, .right, .top, .left]
    }

    func angle() -> CGFloat {
        let multiplier: CGFloat
        switch self {
        case .bottom: multiplier = 0.0
        case .right: multiplier = 0.5
        case .top: multiplier = 1.0
        case .left: multiplier = 1.5
        }
        return .pi * -multiplier
    }

    mutating func rotate() {
        switch self {
        case .bottom: self = .right
        case .right: self = .top
        case .top: self = .left
        case .left: self = .bottom
        }
    }

}

final class BoardViewController: UIViewController {

    var delegate: BoardInteractionDelegate?

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

    public private(set) var currentOrientation: BoardOrientation = .bottom
    func rotateView() {
        self.currentOrientation.rotate()
        UIView.animate(withDuration: 0.3) {
            self.view.transform = self.view.transform.rotated(by: .pi * -0.5)
        }
    }

}

extension UIView: BoardPresenter { }
extension BoardViewController {

    func userDidTap(_ gesture: UITapGestureRecognizer) {
        if let square = view.square(for: gesture.location(in: view)) {
            switch panGesture.isEnabled {
            case true:
                delegate?.userDidTap(on: square)
                panGesture.isEnabled = false
            case false:
                delegate?.userDidRelease(on: square)
                panGesture.isEnabled = true
            }
        }
    }

    func userDidPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        guard let square = view.square(for: location) else {
            delegate?.userDidRelease(on: nil)
            return
        }
        switch gesture.state {
        case .began:
            tapGesture.isEnabled = false
            delegate?.userDidTap(on: square)
        case .changed:
            delegate?.userDidMove(to: square, at: location)
        case .ended, .failed, .cancelled:
            delegate?.userDidRelease(on: square)
            tapGesture.isEnabled = true
        case .possible:
            return
        }
    }

}
