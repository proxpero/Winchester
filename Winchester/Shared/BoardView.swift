//
//  BoardView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame
import SpriteKit

protocol BoardViewDelegate {
    mutating func didBeginActivity(on origin: Square)
    mutating func didMovePiece(to square: Square)
    mutating func didEndActivity(with move: Move, for pieceNode: Piece.Node)
    mutating func didNormalizeActivity()
}

protocol BoardViewDataSource {
    func pieceNode(for origin: Square) -> Piece.Node?
}

protocol BoardViewControllerType: class {

    var boardViewDelegate: BoardViewDelegate? { get set }
    var boardViewDataSource: BoardViewDataSource? { get set }

    func userDidSelect(on square: Square)
    func userDidMove(to square: Square, at location: CGPoint)
    func userDidRelease(on square: Square?)

    var _interactionState: BoardView.InteractionState { get set }
    var _initialSquare: Square? { get set }
    weak var _activeNode: Piece.Node? { get set }
    func _setInteractionState(to newState: BoardView.InteractionState)

}

extension BoardViewControllerType {

    func _beginActivity(for origin: Square) {

        guard let node = boardViewDataSource?.pieceNode(for: origin) else {
            _setInteractionState(to: .normal)
            return
        }

        _activeNode = node
        _initialSquare = origin
        boardViewDelegate?.didBeginActivity(on: origin)

    }

    func _normalizeActivity() {

        _initialSquare = nil
        _activeNode = nil
        boardViewDelegate?.didNormalizeActivity()

    }

    func _endActivity(with move: Move) {

        defer { _setInteractionState(to: .normal) }
        guard let node = _activeNode else { fatalError("Expected a pieceNode") }
        boardViewDelegate?.didEndActivity(with: move, for: node)

    }

    func _setInteractionState(to newState: BoardView.InteractionState) {

        switch newState {
        case .initiation(let origin):
            _beginActivity(for: origin)
        case .normal:
            _normalizeActivity()
        case .end(let move):
            _endActivity(with: move)
        }

    }

    func userDidSelect(on square: Square) {

        switch _interactionState {
        case .initiation(let origin):
            _setInteractionState(to: .end(Move(origin: origin, target: square)))
        case .normal:
            _setInteractionState(to: .initiation(square))
        case .end(let move):
            fatalError("unexpected state where move: \(move), selected square: \(square), initial square: \(_initialSquare)")
        }

    }

    func userDidMove(to square: Square, at location: CGPoint) {

        guard case .initiation = _interactionState, let node = _activeNode else { return }
        node.position = (node.scene?.convertPoint(fromView: location))!
        boardViewDelegate?.didMovePiece(to: square)

    }

    func userDidRelease(on square: Square?) {

        guard
            let target = square,
            case .initiation(let origin) = _interactionState
        else {
            _setInteractionState(to: .normal)
            return
        }
        _setInteractionState(to: .end(Move(origin: origin, target: target)))
        
    }
    
}

enum BoardView { }

extension BoardView {

    struct DataSource: BoardViewDataSource {

        private let pieceNodeDataSource: PieceNodeDataSource

        init(pieceNodeDataSource: PieceNodeDataSource) {
            self.pieceNodeDataSource = pieceNodeDataSource
        }

        func pieceNode(for origin: Square) -> Piece.Node? {
            return pieceNodeDataSource.pieceNode(for: origin)
        }

    }

    enum InteractionState {
        case initiation(Square)
        case normal
        case end(Move)
    }

    enum Orientation {

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

        static var all: [Orientation] {
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
    
}
