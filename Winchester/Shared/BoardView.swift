//
//  BoardView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame

public final class BoardView: SKView, BoardViewType {

    // MARK: Stored Properties

    // BoardViewType
    weak public var pieceCapturingViewDelegate: PieceCapturingViewDelegate?

    // BoardInteractionProtocol

    /// The current state in the user's interaction with the board.
    internal var interactionState: BoardView.InteractionState = .dormant

    /// The initial square selected during a board interaction.
    internal var initialSquare: Square?
    internal weak var activeNode: Piece.Node?

    /// The orientation of white's starting position on the board.
    public var currentOrientation: BoardView.Orientation = .bottom {
        didSet {
            self.transform = CGAffineTransform.identity.rotated(by: currentOrientation.angle())
        }
    }

    /// Create the scene and present it, and layout board's squares.
    public func present() {
        let scene = SKScene()
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        presentScene(scene)
        present(Square.all, as: .normal)
    }

    public var boardTexture: SKTexture {
        guard
            let scene = scene,
            let texture = texture(from: scene)
            else { fatalError("Could not create board texture.") }
        return texture
    }

    internal func blur(with duration: TimeInterval, completion: @escaping () -> Void) {
        guard let scene = scene else { return }
        let radiusKey = "inputRadius"
        let filterName = "CIGaussianBlur"
        let blurFilter = CIFilter(name: filterName, withInputParameters: [radiusKey: 1.0])
        scene.filter = blurFilter
        scene.shouldEnableEffects = true
        let maxRadius: CGFloat = 45
        let blurAction = SKAction.customAction(withDuration: duration) { (node, elapsed) -> Void in
            let radius = (CGFloat(elapsed)/CGFloat(duration)) * maxRadius
            blurFilter?.setValue(radius, forKey: radiusKey)
        }
        scene.run(blurAction, completion: completion)

    }

    public func rotateView() {
        currentOrientation.rotate()
        SKView.animate(withDuration: 0.3) {
            self.transform = self.transform.rotated(by: .pi * -0.5)
        }
    }

}

