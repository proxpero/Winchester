//
//  BoardView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

public protocol BoardViewType: class, BoardViewProtocol, PieceNodeDataSource, PieceNodeCaptureProtocol, HistoryTraversable, PromotionNodeProtocol { }

public final class BoardScene: SKScene {

    let boardNode: SKNode
    private let blurNode: SKEffectNode

    override init() {

        self.boardNode = SKNode()
        self.blurNode = SKEffectNode()
        super.init(size: .zero)
        blurNode.position = position
        
        blurNode.shouldEnableEffects = false
        blurNode.addChild(boardNode)
        addChild(blurNode)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill
    }

    func blur(with duration: Double, completion: @escaping () -> Void) {

        let blur = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 1.0])
        scene?.filter = blur
        scene?.shouldEnableEffects = true
        let blurMax: CGFloat = 45
        let blurAction = SKAction.customAction(withDuration: duration) { (node:SKNode!, elapsed: CGFloat) -> Void in
            blur?.setValue((CGFloat(elapsed) / CGFloat(duration))*blurMax, forKey: "inputRadius")
        }
        scene?.run(blurAction, completion: completion)
    }

}

public final class BoardView: SKView, BoardViewType {

    // BoardViewType
    weak public var capturingViewDelegate: CapturingViewDelegate?

    // BoardInteractionProtocol
    var interactionState: BoardView.InteractionState = .dormant
    var initialSquare: Square?
    weak var activeNode: Piece.Node?

    public var currentOrientation: BoardView.Orientation = .bottom {
        didSet {
            self.transform = CGAffineTransform.identity.rotated(by: currentOrientation.angle())
        }
    }

    public func present() {
        let scene = BoardScene()
        presentScene(scene)
        present(Square.all, as: .normal)
    }

    public var boardTexture: SKTexture {
        return texture(from: scene!)!
    }
}

extension BoardView {

    public func presentPromotion(for color: Color, completion: @escaping (Piece) -> Void) {

        guard let scene = scene as? BoardScene else { fatalError() }
        let gesture = UITapGestureRecognizer()
        scene.blur(with: 0.2) {

            let promotionNode = PromotionNode(pieceColor: color, background: self.boardTexture) { promotion in
                self.removeGestureRecognizer(gesture)
                completion(promotion)
            }
            gesture.addTarget(promotionNode, action: .handlePromotion)
            self.addGestureRecognizer(gesture)
            scene.addChild(promotionNode)
            scene.filter = nil

        }

    }

}

fileprivate extension Selector {
    static let handlePromotion = #selector(PromotionNode.handlePromotion(_:))
}

extension BoardView {

    public enum InteractionState {
        case dormant
        case active(Square)
        case ended(Move)
    }

    public enum Orientation {

        case bottom
        case right
        case top
        case left

        init(angle: CGFloat) {
            let twoPi: CGFloat = 2.0 * .pi
            var ref = angle
            while ref > twoPi {
                ref -= twoPi
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

        public func angle() -> CGFloat {
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

extension BoardView {
    public func rotateView() {
        currentOrientation.rotate()
        SKView.animate(withDuration: 0.3) {
            self.transform = self.transform.rotated(by: .pi * -0.5)
        }
    }
}

extension BoardView: BoardViewProtocol {

    // MARK: Square Nodes

    public var squareNodes: [Square.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Square.Node }
    }

    private func createSquareNode(with square: Square, ofKind kind: Square.Kind) -> Square.Node {
        let node = Square.Node(kind: kind, for: square)
        node.size = squareSize
        node.position = position(for: square)
        return node
    }

    private func addSquareNode(for square: Square, ofKind kind: Square.Kind) {
        let node = createSquareNode(with: square, ofKind: kind)
        _add(node)
    }

    public func present(_ squares: [Square], as kind: Square.Kind) {
        clearSquareNodes(ofKind: kind)
        for square in squares {
            addSquareNode(for: square, ofKind: kind)
        }
    }

    public func clearSquareNodes(ofKind kind: Square.Kind) {
        squareNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    public func clearSquareNodes() {
        Square.Kind.decorators.forEach(clearSquareNodes)
    }

    // MARK: Piece Nodes 

    // All the `PieceNode`s in the scene.
    public var pieceNodes: [Piece.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Piece.Node }
    }

    /// Takes a `PieceNode` and places it in the scene at `origin`'s location.
    public func add(_ pieceNode: Piece.Node, at origin: Square) {
        pieceNode.position = position(for: origin)
        _add(pieceNode)
    }

//    /// Removes `pieceNode` from the scene.
    public func remove(_ pieceNode: Piece.Node) {
        _remove(pieceNode)
    }

    /// Animates the position of `pieceNode` to the location of `target`
    public func move(_ pieceNode: Piece.Node, to target: Square) {
        pieceNode.run(_move(to: target))
    }

    public func updatePieces(with board: Board) {
        pieceNodes.forEach { $0.removeFromParent() }
        for space in board {
            if let piece = space.piece {
                add(pieceNode(for: piece), at: space.square)
            }
        }
    }

    // MARK: Arrow Nodes

    private var arrowNodes: [Arrow.Node] {
        guard let scene = scene else { return [] }
        return scene.children.flatMap { $0 as? Arrow.Node }
    }

    /// Creates a new ArrowNode.
    private func createArrowNode(for move: Move, with kind: Arrow.Kind) -> Arrow.Node {

        let edge = squareSize.width

        let path = CGPath.arrow(
            origin: position(for: move.origin),
            target: position(for: move.target),
            tailWidth: kind.tailWidth(for: edge),
            headWidth: kind.headWidth(for: edge),
            headLength: kind.headLength(for: edge),
            originOffset: kind.originOffset(for: edge),
            targetOffset: kind.targetOffset(for: edge)
            )

        let node = Arrow.Node(move: move, kind: kind, path: path)
        node.zPosition = NodeType.arrow.zPosition
        node.fillColor = kind.fillColor
        node.strokeColor = kind.strokeColor

        return node
    }

    public func presentArrows(for moves: [Move], ofKind kind: Arrow.Kind) {
        removeArrows(with: kind)
        for move in moves {
            addArrow(for: move, with: kind)
        }
    }

    func addArrow(for move: Move, with kind: Arrow.Kind) {
        let node = createArrowNode(for: move, with: kind)
        node.alpha = 0.0
        scene?.addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.2))
    }

    public func removeArrows(with kind: Arrow.Kind) {
        arrowNodes
            .filter { $0.kind == kind }
            .forEach(_remove)
    }

    public func removeAllArrows() {
        Arrow.Kind.all.forEach(removeArrows)
    }

    private func _remove(_ node: SKNode) {
        node.run(SKAction.fadeOut(withDuration: 0.2)) {
            node.removeFromParent()
        }
    }

    private func _add(_ node: SKNode) {
        node.alpha = 0.0
        scene?.addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.2))
    }

    private func _move(to target: Square) -> SKAction {
        let action = SKAction.move(to: position(for: target), duration: 0.2)
        action.timingMode = .easeInEaseOut
        return action
    }
}
