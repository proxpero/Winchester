//
//  HistoryViewDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 10/19/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

protocol HistoryViewDelegate {
    /// Called when the user taps a cell in the HistoryView.
    func userDidSelectHistoryItem(at itemIndex: Int?)
}
