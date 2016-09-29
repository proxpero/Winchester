//
//  GameScene.swift
//  Engine
//
//  Created by Todd Olsen on 8/15/16.
//
//

import Engine
import SpriteKit

public final class GameScene: SKScene {

    let squaresLayer: SquaresLayer
    let piecesLayer: PiecesLayer

    public init(edge: CGFloat) {

        let size = CGSize(width: edge, height: edge)
        self.squaresLayer = SquaresLayer(size: size)
        self.piecesLayer = PiecesLayer(size: size)

        super.init(size: size)

        isUserInteractionEnabled = true
        scaleMode = .aspectFill
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMove(to view: SKView) {

        add(layer: squaresLayer)
        squaresLayer.name = "Squares"
        squaresLayer.zPosition = 100
        squaresLayer.position = view.center
        squaresLayer.setupSquares()
        squaresLayer.color = .white

        addChild(piecesLayer)
        piecesLayer.name = "Pieces"
        piecesLayer.zPosition = 200
        piecesLayer.position = view.center
        piecesLayer.setupPieces(for: Board())

        #if os(iOS)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:))))
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panAction(sender:))))
        #endif

    }

    func move(pieceFrom origin: Square, to target: Square, capture: Capture? = nil) {
        guard let _ = piecesLayer.node(for: origin) else {
            fatalError("Could not find piece at \(origin)")
        }
        piecesLayer.movePiece(from: origin, to: target, animated: true)
        if let capture = capture {
            let captureNode = piecesLayer.createPieceNode(from: capture.piece, location: capture.square)
            captureNode.alpha = 0.0
            piecesLayer.addChild(captureNode)
            captureNode.run(SKAction.fadeIn(withDuration: 0.2))
        }

    }

    /**
     Returns a `Square` corresponding to the given location.
     */
    func square(at location: CGPoint) -> Square? {

        let offset = size.width / 8.0

        // Determine which partition of the board (0..<8) the coordinate occupies.
        func partitionForCoordinate(_ coordinate: CGFloat) -> Int {
            var boundry = CGFloat.greatestFiniteMagnitude
            var partition = 8
            while (coordinate < boundry) && (partition > 0) {
                partition -= 1
                boundry = offset * CGFloat(partition)
            }
            return partition
        }
        return Square(file: File(index: partitionForCoordinate(location.x)),
                      rank: Rank(index: partitionForCoordinate(location.y)))
    }

    /**
     Returns the `SquareNode` for the given `Square`
     */
    public func squareNode(for square: Square) -> SquareNode {
        guard let squareNode = squaresLayer.children.filter({ $0.name == square.description }).first as? SquareNode else { fatalError() }
        return squareNode
    }

    private func add<T>(layer: T) where T: GameLayer, T: SKNode {
        addChild(layer)
        layer.name = ""
    }

}

protocol GameSceneDelegate {
    func availableMoves(from origin: Square) -> Bitboard
}
