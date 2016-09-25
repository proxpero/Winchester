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
        case newGame
        case userGames
        case greatGames
        case puzzles

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        static let count = Section.all.count

        var title: String {
            switch self {
            case .newGame: return "New Game"
            case .userGames: return "My Games"
            case .greatGames: return "Great Games"
            case .puzzles: return "Puzzles"
            }
        }

        static var all: [Section] {
            return [.newGame, .userGames, .greatGames, .puzzles]
        }
    }

    var userGames

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .newGame: return 1
        case .userGames: return 2
        case .greatGames: return 4
        case .puzzles: return 67
        default:
            <#code#>
        }
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



