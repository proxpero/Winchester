//
//  PromotionViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/31/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class PromotionViewController: UIViewController {

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

    @IBOutlet var queenButton: UIButton!
    @IBOutlet var rookButton: UIButton!
    @IBOutlet var bishopButton: UIButton!
    @IBOutlet var knightButton: UIButton!

    var completion: (Piece) -> () = { _ in }
    
    var color: Color = .white {
        didSet {
            for (kind, button) in zip([Piece.Kind.queen, Piece.Kind.rook, Piece.Kind.bishop, Piece.Kind.knight], [queenButton, rookButton, bishopButton, knightButton]) {
                let imageName = "\(color == .white ? "White" : "Black")\(kind.name)"
                button?.setImage(UIImage.init(named: imageName), for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        queenButton.tag = PromotionType.queen.rawValue
        rookButton.tag = PromotionType.rook.rawValue
        bishopButton.tag = PromotionType.bishop.rawValue
        knightButton.tag = PromotionType.knight.rawValue
    }

    @IBAction func promotionSelected(_ sender: UIButton) {
        self.dismiss(animated: true) {
            let promotionType = PromotionType(rawValue: sender.tag)!
            let piece = promotionType.piece(for: self.color)
            self.completion(piece)
        }
    }
    
}