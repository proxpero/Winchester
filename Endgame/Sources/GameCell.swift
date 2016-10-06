//
//  GameCell.swift
//  Endgame
//
//  Created by Todd Olsen on 9/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Engine

public protocol Reusable: class {
    static func reuseIdentifier() -> String
}

extension Reusable {
    public static func reuseIdentifier() -> String {
        return "\(Self.self)"
    }
}

final public class GameCell: UITableViewCell, Reusable {

}
