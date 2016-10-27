//
//  PromotionView.swift
//  NewGameDemo
//
//  Created by Todd Olsen on 10/13/16.
//  Copyright © 2016 proxpero. All rights reserved.
//

//#if os(OSX)
//    import Cocoa
//    typealias View = NSView
//    typealias Button = NSButton
//    typealias Image = NSImage
//#elseif os(iOS) || os(tvOS)
//    import UIKit
//    typealias View = UIView
//    typealias Button = UIButton
//    typealias Image = UIImage
//#endif

import UIKit
import Endgame

final class PromotionView: UIView {

    enum PromotionType: Int {
        case queen
        case rook
        case bishop
        case knight

        func piece(for color: Color) -> Piece {
            switch  self {
            case .queen: return Piece(queen: color)
            case .rook: return Piece(rook: color)
            case .bishop: return Piece(bishop: color)
            case .knight: return Piece(knight: color)
            }
        }
    }

    var completion: (Piece) -> () = { _ in }

    var color: Color = .white {
        didSet {
            for (kind, button) in zip([Piece.Kind.queen, Piece.Kind.rook, Piece.Kind.bishop, Piece.Kind.knight], [queenButton, rookButton, bishopButton, knightButton]) {
                let imageName = "\(color == .white ? "White" : "Black")\(kind.name)"
                button?.setImage(UIImage.init(named: imageName), for: .normal)
            }
        }
    }

    @IBOutlet var queenButton: UIButton!
    @IBOutlet var rookButton: UIButton!
    @IBOutlet var bishopButton: UIButton!
    @IBOutlet var knightButton: UIButton!

    @IBAction func promotionSelected(_ sender: UIButton) {
        let promotionType = PromotionType(rawValue: sender.tag)!
        let piece = promotionType.piece(for: color)
        completion(piece)
    }
}
