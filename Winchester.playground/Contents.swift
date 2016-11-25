import UIKit
import Endgame
import Winchester

//let image = UIImage(named: "test.tiff")!

//let view = UIImageView(image: image)
//view.transform = CGAffineTransform(rotationAngle: .pi * 2.0)
//let png = view.

extension UIImage {
    convenience init?(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard
            let image = UIGraphicsGetImageFromCurrentImageContext(),
            let cgImage = image.cgImage
            else { return nil }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
}

//let rotated = UIImage(view: view)


extension CGFloat {
    var toDegrees: CGFloat {
        return (self * 180.0) / .pi
    }
    var toRadians: CGFloat {
        return (self / 180.0) * .pi
    }
}

extension UIImage {

    public func rotate() -> UIImage {

        UIGraphicsBeginImageContext(size)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.rotate(by: .pi * 2.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsGetCurrentContext()
        return image

    }

    public func rotated(by degrees: CGFloat, flip: Bool) -> UIImage {

        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degrees.toRadians);
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()!

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

        // Rotate the image context
        bitmap.rotate(by: degrees.toRadians)

        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat

        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }

        bitmap.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)

        bitmap.draw(self.cgImage!, in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage

    }
}



