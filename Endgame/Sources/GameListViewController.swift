//
//  GameListViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/13/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

/// Displays the "New Game" button as a table cell, a list of the user's saved games, and a list of games of historical interest.
class GameListViewController: UITableViewController {

    enum Section: Int {
        case newGame = 0
        case userGames = 1
        case historicGames = 2

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        static let count = 3

        var title: String {
            switch self {
            case .newGame: return "New Game"
            case .userGames: return "My Games"
            case .historicGames: return "Saved Games"
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }


    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .newGame:
            return 1
        case .userGames:
            
        }
    }
*/
    



}



