//
//  BoardInteractionProtocol.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import CoreGraphics
import Endgame

protocol BoardInteractionProtocol: class {

    var boardView: BoardView { get }
    weak var delegate: BoardViewDelegate? { get }

    func userDidSelect(_ square: Square)
    func userDidDragPiece(to location: CGPoint)
    func userDidRelease(on square: Square?)

    var state: BoardView.InteractionState { get set }
    var initialSquare: Square? { get set }
    weak var activeNode: Piece.Node? { get set }

}

extension BoardInteractionProtocol {

    private func normalize() {
        initialSquare = nil
        activeNode = nil
        delegate?.boardViewDidNormalizeActivity(boardView)
    }

    private func beginActivity(for square: Square) {
        guard let node = boardView.pieceNode(for: square) else {
            enter(.dormant)
            return
        }
        activeNode = node
        initialSquare = square
        delegate?.boardView(boardView, didBeginActivityOn: square)
    }

    private func endActivity(for move: Move) {
        defer {
            enter(.dormant)
        }
        guard let node = activeNode else { fatalError("Expected a pieceNode") }
        delegate?.boardView(boardView, didEndActivityWith: move, for: node)
    }

    private func enter(_ newState: BoardView.InteractionState) {

        state = newState
        switch newState {
        case .dormant:
            normalize()
        case .active(let origin):
            beginActivity(for: origin)
        case .ended(let move):
            endActivity(for: move)
        }
    }

    func userDidSelect(_ square: Square) {

        switch state {
        case .active(let origin):
            enter(.ended(Move(origin: origin, target: square)))
        case .dormant:
            enter(.active(square))
        case .ended(let move):
            fatalError("unexpected state where move: \(move), selected square: \(square), initial square: \(initialSquare)")
        }

    }

    func userDidDragPiece(to location: CGPoint) {

        guard case .active = state, let node = activeNode, let newPosition = node.scene?.convertPoint(fromView: location) else {
            normalize()
            return
        }
        node.position = newPosition

        guard let target = boardView.square(for: location, isViewFlipped: true) else { return }
        delegate?.boardView(boardView, didMovePieceTo: target)

    }

    func userDidRelease(on square: Square?) {

        guard let square = square else { enter(.dormant); return }
        
        switch state {
        case .active(let origin):
            enter(.ended(Move(origin: origin, target: square)))
        default:
            enter(.dormant)
        }
    }

}
