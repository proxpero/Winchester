//
//  BoardViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

#if os(OSX)
    import Cocoa
    typealias ViewController = NSViewController
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias ViewController = UIViewController
#endif

import SpriteKit
import Engine

internal final class BoardViewController: ViewController {

    override func viewDidLayoutSubviews() {
        guard let skview = view as? SKView else { return }
        let scene = GameScene(edge: view.bounds.width)
        skview.presentScene(scene)
        scene.userDidSelect = userDidSelect
    }

    var scene: GameScene {
        guard
            let skview = view as? SKView,
            let scene = skview.scene as? GameScene
        else { fatalError("There is no scene!") }
        return scene
    }

    var userDidSelect: (Square) -> () = { _ in }

    func pieceNode(for square: Square) -> PieceNode? {
        return scene.piecesLayer.node(for: square)
    }

    func position(for square: Square) -> CGPoint {
        return scene.squaresLayer.position(for: square)
    }

    func newPieceNode(for piece: Piece) -> PieceNode {
        return scene.piecesLayer.pieceNode(for: piece)
    }

    func perform(_ transaction: Transaction, on pieceNode: PieceNode) {
        scene.piecesLayer.perform(transaction, on: pieceNode)
    }

    func execute(move: Move) {

        func action(to target: Square) -> SKAction {
            let action = SKAction.move(to: position(for: target), duration: 0.2)
            action.timingMode = .easeInEaseOut
            return action
        }

        if let capturedNode = pieceNode(for: move.target) {
            capturedNode.zPosition -= 10
            capturedNode.run(SKAction.fadeOut(withDuration: 0.2)) {
                capturedNode.removeFromParent()
            }
        }

        if move.isCastle() {
            let (old, new) = move.castleSquares()
            guard let rookNode = pieceNode(for: old) else {
                fatalError("Expected a rook at \(old.description)")
            }
            rookNode.run(action(to: new))
        }

        guard let movingNode = pieceNode(for: move.origin) else {
            fatalError("Unable to find the expected pieceNode at \(move.origin)")
        }
        movingNode.run(action(to: move.target))
    }

    func showLastMove(_ move: Move?) {
        scene.arrowsLayer.setLastMoveArrow(with: move)
    }

    func addArrow(for move: Move, with type: ArrowType) {

    }

    func highlightAvailableTargets(using squares: [Square]) {
        squares
            .map { scene.squaresLayer.squareNode(for: $0) }
            .forEach { $0.highlightType = .available }
    }

    func removeHighlights() {
        scene.squaresLayer.nodes
            .filter { $0.highlightType != .none }
            .forEach { $0.highlightType = .none }
    }

}

