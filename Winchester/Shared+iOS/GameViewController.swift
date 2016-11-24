//
//  GameViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 8/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Endgame
import Shared

open class GameViewController: UIViewController, GameViewControllerType {
    public typealias B = BoardViewController
    public typealias H = HistoryViewController


    var didTapSettingsButton: () -> () = { }
    var didTapBackButton: () -> () = { }

    @IBOutlet var stackView: UIStackView!

    public var game: Game?

    public var boardViewController: B?
    public var historyViewController: H?
    public var capturedPiecesViewController: CapturedPiecesViewController?

    public var availableTargetsCache: [Square] = []

    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        didTapSettingsButton()
    }

    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        didTapBackButton()
    }

    // Lifecycle

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let game = game else { return }
        let itemIndex: Int?
        if game.isEmpty || game.outcome != .undetermined {
            itemIndex = nil
        } else {
            itemIndex = game.endIndex-1
        }
        game.setIndex(to: itemIndex)
        historyViewController?.selectCell(at: itemIndex)
    }

    public func selectMostRecentMove() {
        guard let game = game else { return }
        let itemIndex: Int? = game.isEmpty ? nil : game.endIndex-1
        game.setIndex(to: itemIndex)
        historyViewController?.selectCell(at: itemIndex)
    }

    private var _isNotVisited = true

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if _isNotVisited {
            addChildViewController(boardViewController!)
            stackView.addArrangedSubview(boardViewController!.view)
            boardViewController!.didMove(toParentViewController: self)

            addChildViewController(historyViewController!)
            stackView.addArrangedSubview(historyViewController!.view)
            historyViewController!.didMove(toParentViewController: self)

            addChildViewController(capturedPiecesViewController!)
            stackView.addArrangedSubview(capturedPiecesViewController!.view)
            capturedPiecesViewController!.didMove(toParentViewController: self)
            _isNotVisited = false
        }

    }

}
