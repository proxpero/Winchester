//
//  ChessGamesViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 11/20/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class GameCollectionViewController: UICollectionViewController {

    enum Item {
        case game(Game)
        case create
    }

    weak var delegate: GameCollectionViewControllerDelegate?

    var opponent: Opponent? = nil {
        didSet {
            items = []
            if let opponent = opponent {
                items = opponent.history.reversed().map { .game($0) }
            }
            items.insert(.create, at: 0)
            collectionView?.reloadData()
        }
    }

    fileprivate var items: [Item] = []

}

extension GameCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .create:
            delegate?.gameCollectionViewControllerDidSelectCreate(self)
        default:
            break
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]

        switch item {
        case .game(let game):
            return dequeueGameCell(for: game, at: indexPath)
        case .create:
            return collectionView.dequeueCell(ofType: CreateCell.self, at: indexPath)
        }
    }

    private func dequeueGameCell(for game: Game, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueCell(ofType: GameCell.self, at: indexPath) else { fatalError() }

        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = GameImageCache.cache
        cell.imageView.image = cache.placeholderImage

        cache.image(for: game) { image in
            OperationQueue.main.addOperation {
                guard cell.representedGame?.currentPosition == game.currentPosition else { return }
                cell.imageView.image = image
            }
        }

        return cell
    }

}

protocol GameCollectionViewControllerDelegate: class {
    /// Called when a user chooses to play a new chess game. 
    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController)
}
