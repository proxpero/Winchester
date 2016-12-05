//
//  GameCollectionViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 11/28/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

public typealias GameCollection = Dictionary<String, Game>

public final class GameCollectionViewController: UICollectionViewController {

    public weak var delegate: GameCollectionViewControllerDelegate?
    public weak var dataSource: GameCollectionViewControllerDataSource?

}

extension GameCollectionViewController {

    public struct Section {

        public let title: String
        public let items: [Item]

        public init(title: String, items: [Item]) {
            self.title = title
            self.items = items
        }

        func item(at indexPath: IndexPath) -> Item {
            return items[indexPath.row]
        }

        func configure(_ header: HeaderCell) {
            header.label.text = title
        }

    }

    public enum Item {
        case create
        case game(game: Game)
        case showMore
    }

}

extension GameCollectionViewController {

    // MARK: - Collection View Data Source

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.sections.count ?? 0
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.sections[section].items.count ?? 0
    }

    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueHeader(ofType: HeaderCell.self, at: indexPath)
        dataSource?.sections[indexPath.section].configure(header)
        return header
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else { fatalError() }
        let item = dataSource.item(at: indexPath)

        switch item {
        case .game:
            return dequeueGameCell(at: indexPath)
        case .create:
            return dequeueCreateCell(at: indexPath)
        case .showMore:
            return dequeueShowMoreCell(at: indexPath)
        }

    }

    private func dequeueGameCell(at indexPath: IndexPath) -> GameCell {
        guard
            let cell = collectionView?.dequeueCell(ofType: GameCell.self, at: indexPath),
            let item = dataSource?.item(at: indexPath),
            case .game(let game) = item
        else { fatalError() }
        cell.representedGame = game
        return cell
    }

    private func dequeueCreateCell(at indexPath: IndexPath) -> CreateCell {
        guard let cell = collectionView?.dequeueCell(ofType: CreateCell.self, at: indexPath) else { fatalError() }
        return cell
    }

    private func dequeueShowMoreCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: "ShowMoreCell", for: indexPath) else { fatalError() }
        return cell
    }

    // MARK: - Collection View Delegate

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let selectedItem = dataSource?.item(at: indexPath) else { return }
        switch selectedItem {
        case .game(let game):
            delegate?.gameCollectionViewController(self, didSelect: game)
        case .create:
            delegate?.gameCollectionViewControllerDidSelectCreate(self)
        case .showMore:
            guard let section = dataSource?.section(at: indexPath) else { fatalError()
            }
            delegate?.gameCollectionViewControllerDidSelectShowMore(self, for: section)
        }
    }

}
