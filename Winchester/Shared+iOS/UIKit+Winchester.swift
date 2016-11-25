//
//  UIKit+Winchester.swift
//  Winchester
//
//  Created by Todd Olsen on 11/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

extension CGFloat {
    public var toDegrees: CGFloat {
        return (self * 180.0) / .pi
    }
    public var toRadians: CGFloat {
        return (self / 180.0) * .pi
    }
}

extension UISwipeGestureRecognizer {
    public convenience init(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection) {
        self.init(target: target, action: action)
        self.direction = direction
    }
}

extension UIView {
    public func addSwipeGestureRecognizer(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection = .right ) {
        let swipe = UISwipeGestureRecognizer(target: target, action: action, direction: direction)
        addGestureRecognizer(swipe)
    }
}


extension UIImage {

    public convenience init?(view: UIView) {
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

    public func rotated(by degrees: CGFloat, flip: Bool = false) -> UIImage {

        // https://ruigomes.me/blog/how-to-rotate-an-uiimage-using-swift/

        let radians = degrees.toRadians

        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: radians);
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()!

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

        // Rotate the image context
        bitmap.rotate(by: radians)

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

extension UICollectionView {

    public func dequeueCell<A: UICollectionViewCell>(ofType type: A.Type, at indexPath: IndexPath) -> A {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as? A else { fatalError("Could not dequeue cell.") }
        return cell
    }
    
}

extension UIStoryboard {

    public static var game: UIStoryboard {
        let bundle = Bundle(for: GameViewController.self)
        return UIStoryboard(name: "Game", bundle: bundle)
    }

    public func instantiate<A: UIViewController>(_ type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }
    
}



