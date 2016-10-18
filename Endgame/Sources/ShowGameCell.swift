//
//  ShowGameCell.swift
//  Endgame
//
//  Created by Todd Olsen on 10/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

public final class HeaderCell: UICollectionReusableView, ReusableCell {
    @IBOutlet var titleLabel: UILabel!
    var didTapShowAll: () -> () = { }
    var didTapCreateItem: () -> () = { }
    @IBOutlet var showAllButton: UIButton!
    @IBAction func showAllAction(_ sender: UIButton) {
        didTapShowAll()
    }
    @IBOutlet var createItemButton: UIButton!
    @IBAction func createItemAction(_ sender: UIButton) {
        didTapCreateItem()
    }

}

public final class ShowGameCell: UICollectionViewCell, ReusableCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var whiteLabel: UILabel!
    @IBOutlet var blackLabel: UILabel!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var ecoLabel: UILabel!
    @IBOutlet var moveCountLabel: UILabel!
    @IBOutlet var outcomeLabel: UILabel!
}

public final class ShowPuzzleCell: UICollectionViewCell, ReusableCell {

}
