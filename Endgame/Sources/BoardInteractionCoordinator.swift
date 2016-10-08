//
//  BoardInteractionCoordinator.swift
//  NewGameDemo
//
//  Created by Todd Olsen on 10/8/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import Engine
import SpriteKit

final class BoardInteractionCoordinator {

    let userDidExecute: (Move) -> Void

    let pieceNode: (Square) -> PieceNode?
    let position: (Square) -> CGPoint
    let availableTargets: (Square) -> [Square]
    let highlightAvailableTargets: ([Square]) -> Void
    let execute: (Move) -> Void
    let removeHighlights: () -> Void

    init(
        userDidExecute: @escaping (Move) -> Void,
        pieceNode: @escaping (Square) -> PieceNode?,
        position: @escaping (Square) -> CGPoint,
        availableTargets: @escaping (Square) -> [Square],
        highlightAvailableTargets: @escaping ([Square]) -> Void,
        execute: @escaping (Move) -> Void,
        removeHighlights: @escaping () -> Void
    ) {
        self.userDidExecute = userDidExecute
        self.pieceNode = pieceNode
        self.position = position
        self.availableTargets = availableTargets
        self.highlightAvailableTargets = highlightAvailableTargets
        self.execute = execute
        self.removeHighlights = removeHighlights
    }

    private weak var _activeNode: PieceNode?
    private var _initialSquare: Square?

    func userDidSelect(square: Square) {
        switch _activityState {
        case .initiation(let origin):
            _activityState = .end(Move(origin: origin, target: square))
        case .normal:
            _activityState = .initiation(square)
        case .end(let move):
            fatalError("unexpected state where move: \(move), selected square: \(square), initial square: \(_initialSquare)")
        }
    }

    private var _activityState: ActivityState = .normal {
        didSet {
            switch _activityState {
            case .initiation(let origin):
                _beginActivity(for: origin)
            case .normal:
                _normalizeActivity()
            case .end(let move):
                _endActivity(with: move)
            }
        }
    }

    private func _beginActivity(for origin: Square) {
        guard let node = pieceNode(origin) else {
            _activityState = .normal
            return
        }
        _activeNode = node
        _initialSquare = origin
        highlightAvailableTargets(availableTargets(origin))
    }

    private func _normalizeActivity() {
        _initialSquare = nil
        _activeNode = nil
        removeHighlights()
    }

    private func _endActivity(with move: Move) {
        defer {
            _activityState = .normal
        }

        func moveNode(to target: Square) {
            let action = SKAction.move(to: position(target), duration: 0.2)
            action.timingMode = .easeInEaseOut
            _activeNode?.run(action)

        }

        guard availableTargets(move.origin).contains(move.target) else {
            moveNode(to: move.origin)
            return
        }

        userDidExecute(move)
        execute(move)
//        moveNode(to: move.target)
    }

}

