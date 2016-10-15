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

    let userDidExecute: (Move, Piece?) -> Void

    let pieceNode: (Square) -> PieceNode?
    let position: (Square) -> CGPoint
    let availableTargets: (Square) -> [Square]
    let availableCaptures: (Square) -> [Square]
    let highlightAvailableTargets: ([Square]) -> Void
    let highlightAvailableCaptures: ([Square]) -> Void
//    let animateNode: (Move, @escaping PromotionHandler) -> Void
    let removeHighlights: () -> Void

    init(
        userDidExecute: @escaping (Move, Piece?) -> Void,
        pieceNode: @escaping (Square) -> PieceNode?,
        position: @escaping (Square) -> CGPoint,
        availableTargets: @escaping (Square) -> [Square],
        availableCaptures: @escaping (Square) -> [Square],
        highlightAvailableTargets: @escaping ([Square]) -> Void,
        highlightAvailableCaptures: @escaping ([Square]) -> Void,
//        animateNode: @escaping (Move, PromotionHandler) -> Void,
        removeHighlights: @escaping () -> Void
    ) {
        self.userDidExecute = userDidExecute
        self.pieceNode = pieceNode
        self.position = position
        self.availableTargets = availableTargets
        self.availableCaptures = availableCaptures
        self.highlightAvailableTargets = highlightAvailableTargets
        self.highlightAvailableCaptures = highlightAvailableCaptures
//        self.animateNode = animateNode
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
        highlightAvailableCaptures(availableCaptures(origin))
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

//        execute(move) { promotion in
//            self.userDidExecute(move, promotion)
//        }
    }

}

