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

import Engine
import SpriteKit

internal final class BoardViewController: ViewController {

    func perform(item: HistoryItem, direction: Direction) {
        let move = direction.isForward ? item.move : item.move.reversed()
        _scene.perform(move: move)

        if item.move.isCastle() {
            let (rookOrigin, rookTarget) = item.move.castleSquares()
            let rookMove: Move
            if direction.isForward {
                rookMove = Move(origin: rookOrigin, target: rookTarget)
            } else {
                rookMove = Move(origin: rookTarget, target: rookOrigin)
            }
            _scene.perform(move: rookMove)
        }

        if let capture = item.capture {
            if direction.isReverse {
                _scene.replace(capture: capture)
            } else {

            }
        }

        if let promotion = item.promotion {
            
        }

    }

    enum ActivityState {
        case initiation(Square)
        case end(origin: Square, target: Square)
        case normal
    }

    var activityState: ActivityState = .normal {
        didSet {
            switch activityState {
            case .initiation(let origin):
                beginActivity(for: origin)
            case .end(let origin, let target):
                endActivity(with: origin, target: target)
            case .normal:
                normalizeActivity()
            }
        }
    }

    private var _scene: GameScene {
        guard
            let skview = view as? SKView,
            let scene = skview.scene as? GameScene
        else { fatalError("") }
        return scene
    }

    func beginActivity(for origin: Square) {
//        let squareNodes = _scene.squaresLayer.squareNodes(for: availableMoves(origin))
//        for squareNode in squareNodes {
//            squareNode.highlightType = .available
//        }
    }

    func normalizeActivity() {
        _scene.squaresLayer.removeHighlights()
    }

    func endActivity(with origin: Square, target: Square?) {

//        defer {
//            activityState = .normal
//        }
//
//        guard let target = target, availableMoves(origin).contains(target) else {
//            // move piece back to origin
//            return
//        }
//
//        guard execute(Move(origin: origin, target: target)) else {
//            fatalError("Error: no handling in \(#function)")
//        }
//        _scene.piecesLayer.movePiece(from: origin, to: target, animated: true)
    }

    override func viewDidLayoutSubviews() {
        guard let skview = view as? SKView else { return }
        let scene = GameScene(edge: view.bounds.width)
        skview.presentScene(scene)
     }

    func update(with moves: [Move]) {
        
    }

}

protocol GameSceneDataSource {

    func piece(_: GameScene, at square: Square) -> Piece
}
