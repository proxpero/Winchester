
import CoreGraphics
import SpriteKit
import Engine
import UIKit

func image(for view: UIView) -> UIImage {
    UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    return image
}


extension Game {
    public var images: [UIImage] {
        let views = self.map { $0.position.thumbnail(edge: 200) }
        var images = [UIImage]()
        for view in views {
            images.append(image(for: view))
        }
        return images
    }
    
}


//let url = Bundle.main.url(forResource: "fischer v fine", withExtension: "pgn")!
//let file = try! String(contentsOf: url)
//let pgn = try! PGN(parse: file)
//let game = Game(pgn: pgn)

//let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//imageView.animationImages = game.images
//imageView.animationDuration = 1
//imageView.startAnimating()
//
//imageView

