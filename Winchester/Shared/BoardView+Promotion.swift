//
//  BoardView+Promotion.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

extension BoardView {

    public func presentPromotion(for color: Color, completion: @escaping (Piece) -> Void) {

        guard let scene = scene else { fatalError() }
        let gesture = UITapGestureRecognizer()
        blur(with: 0.3) {
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
