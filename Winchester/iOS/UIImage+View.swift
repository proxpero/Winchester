//
//  UIImage+View.swift
//  Winchester
//
//  Created by Todd Olsen on 9/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

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

    func rotated() -> UIImage {
        let imageView = UIImageView(image: self)
        imageView.transform = CGAffineTransform(rotationAngle: .pi * 2.0)
        let rotated = UIImage(view: imageView)!
        return rotated
    }

}
