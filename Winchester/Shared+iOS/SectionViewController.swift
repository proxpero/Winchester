//
//  SectionsViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 1/8/17.
//  Copyright © 2017 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

struct Section {
    var title: String
    var games: [Game]
    let configure: (GameCell, Int) -> ()
    var didSelect: (Int) -> () = { _ in }
    var reuseIdentifier: String
}

final class SectionsViewController: UITableViewController {
    var sections: [Section] = []

    init(sections: [Section]) {
        super.init(style: .plain)
        self.sections = sections
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        for section in sections {
            tableView.register(GameCell.self, forCellReuseIdentifier: section.reuseIdentifier)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].didSelect(indexPath.row)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sections[indexPath.section].reuseIdentifier, for: indexPath) as! GameCell
        sections[indexPath.section].configure(cell, indexPath.row)
        return cell
    }
}
