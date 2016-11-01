//
//  TitleViewDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 10/25/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

protocol TitleViewModel {
    var white: Player { get }
    var black: Player { get }
    var outcome: Outcome { get }
}
