//
//  HistoryCell.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//


import UIKit

final class HistoryCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!
    var isBordered: Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isBordered { return }
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 3, dy: 6), cornerRadius: 6)
        UIColor.darkText.set()
        path.stroke()
        (isSelected ? UIColor.darkGray : UIColor.clear).set()
        path.fill()
    }

    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
            label.textColor = isSelected ? UIColor.white : UIColor.darkText
        }
    }
    
}
