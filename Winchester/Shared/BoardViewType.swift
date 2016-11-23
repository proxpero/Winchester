//
//  BoardViewType.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

public protocol BoardViewType: class, BoardViewProtocol, PieceNodeDataSource, PieceNodeCaptureProtocol, HistoryTraversable, PromotionNodeProtocol {
    
}
