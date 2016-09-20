//
//  CollectionViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

public struct CollectionViewConfiguration<Item> {

    let items: [Item]
    let configureCell: (UICollectionViewCell, Item) -> ()

}

final public class CollectionViewController<Item>: UICollectionViewController {

    let configuration: CollectionViewConfiguration<Item>

    init(configuration: CollectionViewConfiguration<Item>) {
        self.configuration = configuration
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configuration.items.count
    }

}
