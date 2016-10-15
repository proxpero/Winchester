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

    var userDidSelect: (Square) -> () = { _ in }

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

    var blurFilter: CIFilter {
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            fatalError("Could not create filter")
        }
        filter.setDefaults()
        return filter
    }

    func blur() {

        let filter = blurFilter
        filter.setValue(40.0, forKey: "inputRadius")
        self.shouldEnableEffects = true
        self.filter = filter

    }

    func unblur() {
        self.filter = nil
    }

    func showPromotion() {

        let inset = size.width*0.2

        

//        let promotion = UIView(frame: frame.insetBy(dx: inset, dy: inset))

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

extension SKScene {

    var blurred: SKSpriteNode {
        let viewSize = CGSize(width: self.view!.frame.size.width, height: self.view!.frame.size.height)


        let renderer = UIGraphicsImageRenderer(size: size)
        let context = UIGraphicsRendererContext()
        let image_ = renderer.image(actions: { ctx in
            let x = ctx.currentImage
        })

        print(image_)




        UIGraphicsBeginImageContextWithOptions(viewSize, true, 1.0)
        view!.drawHierarchy(in: self.view!.frame, afterScreenUpdates: true)
        _ = UIGraphicsGetCurrentContext()
        let image = UIGraphicsGetImageFromCurrentImageContext()
//        let ciContext = CIContext(options: nil)
//        let coreImage = CIImage(image: image!)
//        let filter = CIFilter(name: "CIGaussianBlur")
//        filter?.setDefaults()
//        filter?.setValue(coreImage, forKey: kCIInputImageKey)
//        filter?.setValue(3.0, forKey: kCIInputRadiusKey)
//        let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
//        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
//        let filteredImage = UIImage(cgImage: filteredImageRef!)
        
        let texture = SKTexture(image: image!)

//        let texture = SKTexture(image: filteredImage)
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let scale = UIScreen.main.scale
        sprite.size.width *= scale
        sprite.size.height *= scale
        return sprite
    }

}
