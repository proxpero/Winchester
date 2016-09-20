//
//  ChessGameViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

final class ChessGameViewController: UIViewController {


    

}

protocol ChessGameViewControllerDelegate {
    func chessGameViewController(didExecute move: Move) -> ()
}
