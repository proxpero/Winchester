//
//  HistoryViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

public protocol HistoryViewDelegate: class {
    /// Called when the user selects a cell in the HistoryView.
    ///
    /// - Parameter itemIndex: The index of the history item in the game.
    func userDidSelectHistoryItem(at itemIndex: Int?)
}
