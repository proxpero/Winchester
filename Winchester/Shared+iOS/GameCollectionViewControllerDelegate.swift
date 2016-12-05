//
//  GameCollectionViewControllerDelegate.swift
//  Winchester
//
//  Created by Todd Olsen on 11/28/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

public protocol GameCollectionViewControllerDelegate: class {

    /// Called when a user chooses to create a new chess game.
    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController)
    func gameCollectionViewControllerDidSelectShowMore(_ controller: GameCollectionViewController, for section: GameCollectionViewController.Section)
    func gameCollectionViewController(_ controller: GameCollectionViewController, didSelect game: Game)
    func gameCollectionViewController(_ controller: GameCollectionViewController, shouldShowSection:  GameCollectionViewController.Section) -> Bool

}

extension GameCollectionViewControllerDelegate {
    public func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController) { }

    public func gameCollectionViewControllerDidSelectShowMore(_ controller: GameCollectionViewController, for section: GameCollectionViewController.Section) { }

    public func gameCollectionViewController(_ controller: GameCollectionViewController, didSelect game: Game) { }

    public func gameCollectionViewController(_ controller: GameCollectionViewController, shouldShowSection: GameCollectionViewController.Section) -> Bool {
        return false
    }
}
