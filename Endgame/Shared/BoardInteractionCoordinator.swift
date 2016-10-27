//
//  BoardInteractionCoordinator.swift
//  NewGameDemo
//
//  Created by Todd Olsen on 10/8/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

import Endgame
import SpriteKit

enum HighlightType {
    case capture
    case target
    case origin
    case vulnerable
    case defended
}

protocol BoardHighlightingCoordinator {
    func highlight(squares: [Square], with type: HighlightType)
    func removeHighlights()
}

extension BoardHighlightingCoordinator {

}

struct BoardInteractionCoordinator: BoardInteractionDelegate {

    // MARK: - Private Stored Properties

    private let delegate: UserActivityDelegate
    private let model: PieceNodeModel

    weak var _activeNode: PieceNode?

    var _initialSquare: Square?
    var _activityState: ActivityState = .normal {
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
            _activityState = .normal
            return
        }
        _activeNode = node
        _initialSquare = origin
        delegate.userDidBeginActivity(on: origin)
    }

    private mutating func _normalizeActivity() {
        _initialSquare = nil
        _activeNode = nil
        delegate.userDidNormalizeActivity()
    }

    private mutating func _endActivity(with move: Move) {
        defer {
            _activityState = .normal
        }
        guard let node = _activeNode else { fatalError("Expected a pieceNode") }
        delegate.userDidEndActivity(with: move, for: node)
    }

    // MARK: - Scene Delegate

    mutating func userDidTap(on square: Square) {

        switch _activityState {
        case .initiation(let origin):
            _endActivity(with: Move(origin: origin, target: square))
        case .normal:
            _activityState = .initiation(square)
        case .end(let move):
            fatalError("unexpected state where move: \(move), selected square: \(square), initial square: \(_initialSquare)")
        }

    }

    func userDidPan(to square: Square?) {
        print("\(#function) with square \(square)")
    }

    func userDidLongTap(on square: Square) {
        print("\(#function) with square \(square)")
    }

    func userDidRelease(on square: Square?) {
        print("\(#function) with square \(square)")
    }

    mutating func userDidCancelSelection() {
        _normalizeActivity()
    }
}
