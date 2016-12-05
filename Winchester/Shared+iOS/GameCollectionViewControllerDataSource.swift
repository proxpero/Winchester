//
//  GameCollectionViewControllerDataSource.swift
//  Winchester
//
//  Created by Todd Olsen on 11/28/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

public protocol GameCollectionViewControllerDataSource: class {

    var sections: [GameCollectionViewController.Section] { get }
    func item(at indexPath: IndexPath) -> GameCollectionViewController.Item
}

extension GameCollectionViewControllerDataSource {

    public func section(at indexPath: IndexPath) -> GameCollectionViewController.Section {
        return sections[indexPath.section]
    }

    public func configure(_ header: HeaderCell, at indexPath: IndexPath) {
        section(at: indexPath).configure(header)
    }

    public func item(at indexPath: IndexPath) -> GameCollectionViewController.Item {
        return section(at: indexPath).item(at: indexPath)
    }

}
