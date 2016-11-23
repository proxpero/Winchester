//
//  PromotionNodeProtocol.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

public protocol PromotionNodeProtocol {
    func presentPromotion(for color: Color, completion: @escaping (Piece) -> Void)
}

