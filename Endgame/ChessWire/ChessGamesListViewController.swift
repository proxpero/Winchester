//
//  ChessGamesListViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

final class ChessGamesListViewController: UICollectionViewController {
    // MARK: Types

    /// An enumeration that represents an item in the collection view.
    enum CollectionViewItem {
        case game(Game)
        case create
    }
    
    // MARK: Properties

    static let storyboardIdentifier = "IceCreamsViewController"

    weak var delegate: ChessGamesListViewControllerDelegate?

    private let items: [CollectionViewItem]

    required init?(coder aDecoder: NSCoder) {
        // Map the previously completed ice creams to an array of `CollectionViewItem`s.
        let reversedHistory = GameHistory.load().reversed()
        var items: [CollectionViewItem] = reversedHistory.map { .game($0) }

        // Add `CollectionViewItem` that the user can tap to start building a new ice cream.
        items.insert(.create, at: 0)

        self.items = items
        super.init(coder: aDecoder)
    }
}

/**
 A delegate protocol for the `ChessGamesListViewController` class.
 */
protocol ChessGamesListViewControllerDelegate: class {
    /// Called when a user choses to create a new `Game` in the `IceCreamsViewController`.
    func gamesListViewControllerDidSelectAdd(_ controller: ChessGamesListViewController)
}
