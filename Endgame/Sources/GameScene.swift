//
//  GameScene.swift
//  Engine
//
//  Created by Todd Olsen on 8/15/16.
//
//

import Engine
import SpriteKit

protocol SceneDelegate: class {
    func didSelect(square: Square)
}

public final class GameScene: SKScene {

    var userDidSelect: (Square) -> () = { _ in
        print(#function)
    }

    let squaresLayer: SquaresLayer
    let arrowsLayer: ArrowsLayer
    let piecesLayer: PiecesLayer

    public init(edge: CGFloat) {

        let size = CGSize(width: edge, height: edge)
        self.squaresLayer = SquaresLayer(size: size)
        self.piecesLayer = PiecesLayer(size: size)
        self.arrowsLayer = ArrowsLayer(size: size)

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

        add(layer: arrowsLayer)
        arrowsLayer.name = "Arrows"
        arrowsLayer.zPosition = 150
        arrowsLayer.position = view.center
        arrowsLayer.color = .clear

        add(layer: piecesLayer)
        piecesLayer.name = "Pieces"
        piecesLayer.zPosition = 200
        piecesLayer.position = view.center
        piecesLayer.setupPieces(for: Board())

//        userDidSelect = userDidSelect

        #if os(iOS)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:))))
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panAction(sender:))))
        #endif
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
    }

}
