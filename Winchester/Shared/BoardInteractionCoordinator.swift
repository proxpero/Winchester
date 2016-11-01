//
//  BoardInteractionCoordinator.swift
//  NewGameDemo
//
//  Created by Todd Olsen on 10/8/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import Endgame
import SpriteKit

enum ActivityState {
    case initiation(Square)
    case normal
    case end(Move)
}

protocol BoardInteractionDelegate {
    mutating func userDidTap(on square: Square)
    mutating func userDidMove(to square: Square, at location: CGPoint)
    mutating func userDidRelease(on square: Square?)
}

struct BoardInteractionCoordinator {

    // MARK: - Private Stored Properties

    fileprivate let delegate: UserActivityDelegate
    private let model: PieceNodeModel

    weak var activeNode: PieceNode?

    var initialSquare: Square?
    var activityState: ActivityState = .normal {
        didSet {
            switch activityState {
            case .initiation(let origin):
                _beginActivity(for: origin)
            case .normal:
                _normalizeActivity()
            case .end(let move):
                _endActivity(with: move)
            }
        }
    }

    // MARK: - Initializers

    init(delegate: UserActivityDelegate,
         model: PieceNodeModel)
    {
        self.delegate = delegate
        self.model = model
    }

    // MARK: - Private Functions

    private mutating func _beginActivity(for origin: Square) {
        guard let node = model.pieceNode(for: origin) else {
            activityState = .normal
            return
        }
        activeNode = node
        initialSquare = origin
        delegate.userDidBeginActivity(on: origin)
    }

    private mutating func _normalizeActivity() {
        initialSquare = nil
        activeNode = nil
        delegate.userDidNormalizeActivity()
    }

    private mutating func _endActivity(with move: Move) {
        defer {
            activityState = .normal
        }
        guard let node = activeNode else { fatalError("Expected a pieceNode") }
        delegate.userDidEndActivity(with: move, for: node)
    }

}

extension BoardInteractionCoordinator: BoardInteractionDelegate {

    // MARK: - Delegate

    mutating func userDidTap(on square: Square) {
        switch activityState {
        case .initiation(let origin):
            activityState = .end(Move(origin: origin, target: square))
        case .normal:
            activityState = .initiation(square)
        case .end(let move):
            fatalError("unexpected state where move: \(move), selected square: \(square), initial square: \(initialSquare)")
        }
    }

    mutating func userDidMove(to square: Square, at location: CGPoint) {
        guard case .initiation = activityState, let node = activeNode else { return }
        node.position = (node.scene?.convertPoint(fromView: location))!
        delegate.userDidPan(to: square)
    }

    mutating func userDidRelease(on square: Square?) {
        guard
            let target = square,
            case .initiation(let origin) = activityState
        else { activityState = .normal; return }
        activityState = .end(Move(origin: origin, target: target))
    }

}
