//
//  ChessGamesViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 11/20/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class ChessGamesViewController: UICollectionViewController {

    enum Item {
        case game(Game)
        case create
    }

    weak var delegate: ChessGamesViewControllerDelegate?

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

extension ChessGamesViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .create:
            delegate?.chessGamesViewControllerDidSelectCreate(self)
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
            return collectionView.dequeueReusableCell(CreateCell.self, at: indexPath)
        }
    }

    private func dequeueGameCell(for game: Game, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(GameCell.self, at: indexPath) else { fatalError() }

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

protocol ChessGamesViewControllerDelegate: class {
    /// Called when a user chooses to play a new chess game. 
    func chessGamesViewControllerDidSelectCreate(_ controller: ChessGamesViewController)
}

extension UICollectionView {

    func dequeueReusableCell<A: UICollectionViewCell>(_ type: A.Type, at indexPath: IndexPath) -> A {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as? A else { fatalError("Could not dequeue cell.") }
        return cell
    }

}
