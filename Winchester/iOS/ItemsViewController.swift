//
//  ItemsViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 1/4/17.
//  Copyright © 2017 Todd Olsen. All rights reserved.
//

import UIKit

final class ItemsViewController<Item, Cell: UITableViewCell>: UITableViewController {
    var items: [Item] = []
    let reuseIdentifier = "Cell"
    let configure: (Cell, Item) -> ()
    var didSelect: (Item) -> () = { _ in }

    init(items: [Item], configure: @escaping (Cell, Item) -> ()) {
        self.configure = configure
        super.init(style: .plain)
        self.items = items
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        didSelect(item)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
        let item = items[indexPath.row]
        configure(cell, item)
        return cell
    }
}
