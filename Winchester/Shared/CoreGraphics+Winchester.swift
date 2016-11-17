//
//  CoreGraphics+Winchester.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import CoreGraphics

extension CGPath {

    static func arrow(origin: CGPoint,
                      target: CGPoint,
                      tailWidth: CGFloat,
                      headWidth: CGFloat,
                      headLength: CGFloat,
                      originOffset: CGFloat = 0.0,
                      targetOffset: CGFloat = 0.0) -> CGPath
    {
        let length = CGFloat(hypot(
            (Double(target.x) - Double(origin.x)),
            (Double(target.y) - Double(origin.y))
        ))

        let points: [CGPoint] = {
            let tailLength = length - headLength - originOffset - targetOffset
            return [
                CGPoint(x: 0 + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: tailWidth / 2),
                CGPoint(x: tailLength + originOffset, y: headWidth / 2),
                CGPoint(x: length - targetOffset, y: 0),
                CGPoint(x: tailLength + originOffset, y: -headWidth / 2),
                CGPoint(x: tailLength + originOffset, y: -tailWidth/2),
                CGPoint(x: 0 + originOffset, y: -tailWidth / 2)
            ]
        }()

        let transform: CGAffineTransform = {
            let cosine = (target.x - origin.x) / length
            let sine = (target.y - origin.y) / length
            return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: origin.x, ty: origin.y)
        }()

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return path.copy()!
    }

}
