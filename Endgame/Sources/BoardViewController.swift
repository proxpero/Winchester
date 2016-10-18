//
//  BoardViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Engine

internal final class BoardViewController: UIViewController {

//    @IBOutlet var promotionView: PromotionView!

    override func viewDidLayoutSubviews() {
        guard let skview = view as? SKView else { return }
        let scene = GameScene(edge: edge())
        skview.presentScene(scene)
        scene.userDidSelect = userDidSelect

//        showPromotion(for: .white) { piece in
//            print(piece)
//        }
    }

    func edge() -> CGFloat {
        return min(view.frame.width, view.frame.height)
    }

//    public override func viewDidLoad() {
//        let inset = edge() * 0.2
//        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: edge(), height: edge()))
//        promotionView.frame = frame.insetBy(dx: inset, dy: inset)
//        promotionView.layer.cornerRadius = inset/3
//        promotionView.layer.borderColor = UIColor.gray.cgColor
//        promotionView.layer.borderWidth = 3.0
//        promotionView.layer.backgroundColor = UIColor(white: 0.8, alpha: 0.4).cgColor
//    }

//    func showPromotion(for color: Color, completion: @escaping (Piece) -> ()) {
//        promotionView.color = color
//        promotionView.center = CGPoint(x: view.frame.midX, y: view.frame.minX)
//        promotionView.alpha = 0.0
//        promotionView.completion = completion
//        view.addSubview(promotionView)
//        scene.blur()
//        UIView.animate(
//            withDuration: 0.6,
//            delay: 0.0,
//            options: .curveEaseInOut,
//            animations: {
//            self.promotionView.center = self.view!.center
//            self.promotionView.alpha = 1.0
//        })
//    }

//    func resetPromotion() {
//        promotionView.removeFromSuperview()
//    }

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

    func add(_ node: PieceNode) {
        scene.piecesLayer.addChild(node)
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

    func animateNode(with move: Move, promotion: @escaping (Piece?) -> ()) {

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
        movingNode.run(action(to: move.target)) {
            let piece = movingNode.piece
            let isPromotion = piece.kind.isPawn && move.target.rank == Rank.init(endFor: piece.color)
            if isPromotion {
//                self.showPromotion(for: piece.color) { newPiece in
//                    let promotionNode = self.newPieceNode(for: newPiece)
//                    promotionNode.position = movingNode.position
//                    promotionNode.zPosition = movingNode.zPosition
//                    promotionNode.alpha = 0.0
//                    promotionNode.run(SKAction.fadeIn(withDuration: 0.2)) {
//                        self.add(promotionNode)
//                    }
//                    promotion(newPiece)
//                }
            }
        }
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

    func highlightAvailableCaptures(using squares: [Square]) {
        squares
            .map { scene.squaresLayer.squareNode(for: $0) }
            .forEach { $0.highlightType = .attacking }
    }

    func removeHighlights() {
        scene.squaresLayer.nodes
            .filter { $0.highlightType != .none }
            .forEach { $0.highlightType = .none }
    }

}

