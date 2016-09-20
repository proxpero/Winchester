//
//  TableViewController.swift
//  Endgame
//
//  Created by Todd Olsen on 9/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit

struct TableViewConfiguration<Item> {

    let items: [Item]
    let style: UITableViewStyle
    var nibName: String?
    let reusableCellClass: Reusable.Type
    let configureCell: (_ cell: UITableViewCell, _ item: Item) -> ()
    let didSelect: (Item) -> ()
    let didTapConfigure: () -> ()

}

final class TableViewController<Item>: UITableViewController {

    let configuration: TableViewConfiguration<Item>

    init(configuration: TableViewConfiguration<Item>) {
        self.configuration = configuration
        super.init(style: configuration.style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let identifier = configuration.reusableCellClass.reuseIdentifier()
        if let nibName = configuration.nibName {
            tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            tableView.register(configuration.reusableCellClass.self, forCellReuseIdentifier: identifier)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuration.items.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = configuration.items[indexPath.row]
        configuration.didSelect(item)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: configuration.reusableCellClass.reuseIdentifier(),
                                                 for: indexPath)
        configuration.configureCell(cell, configuration.items[indexPath.row])
        return cell
    }

}

public protocol Reusable: class {
    static func reuseIdentifier() -> String
}

extension Reusable {
    public static func reuseIdentifier() -> String {
        return "\(Self.self)"
    }
}
