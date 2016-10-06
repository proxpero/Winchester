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
    }

    var scene: GameScene {
        guard
            let skview = view as? SKView,
            let scene = skview.scene as? GameScene
            else { fatalError("There is no scene!") }
        return scene
    }

    func pieceNode(for square: Square) -> PieceNode? {
        return scene.piecesLayer.node(for: square)
    }

    func newPieceNode(for piece: Piece) -> PieceNode {
        return scene.piecesLayer.pieceNode(for: piece)
    }

    func perform(_ transaction: Transaction, on pieceNode: PieceNode) {
        scene.piecesLayer.perform(transaction, on: pieceNode)
    }

}

