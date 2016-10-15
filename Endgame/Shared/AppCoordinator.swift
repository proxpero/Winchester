//
//  AppCoordinator.swift
//  Endgame
//
//  Created by Todd Olsen on 10/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Engine
import UIKit

struct ApplicationCoordinator {

    private let _navigationController: UINavigationController

    init(window: UIWindow) {
        self.navigationController = window.rootViewController as! UINavigationController

    }

    func start() {

    }


}

struct GameCoordinator {

    private let _game: Game

    init(game: Game) {

    }

    

}
