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

struct Design: Equatable {

    let isWide: Bool
    let isBiased: Bool
    let showGridLabels: Bool

    init(size: CGSize, isBiased: Bool = false, showGridLabels: Bool = false) {
        self.isWide = size.width > size.height
        self.isBiased = isBiased
        self.showGridLabels = showGridLabels
    }

    var axis: UILayoutConstraintAxis {
        return isWide ? .horizontal : .vertical
    }

    static func == (lhs: Design, rhs: Design) -> Bool {
        return lhs.isWide == rhs.isWide && lhs.isBiased == rhs.isBiased && lhs.showGridLabels == rhs.showGridLabels
    }

}

final class GameViewController: UIViewController, GameViewControllerType {

    var didTapSettingsButton: () -> () = { }
    var didTapBackButton: () -> () = { }
    var presentScene: () -> Void  =  { }

    @IBOutlet var stackView: UIStackView!

    var game: Game?

    var boardViewController: BoardViewController?
    var historyViewController: HistoryViewController?
    var capturedViewController: CapturedViewController?

    var availableTargetsCache: [Square] = []

    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        didTapSettingsButton()
    }

    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        didTapBackButton()
    }

    var displayedDesign: Design? = nil

    // Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newDesign = Design(size: view.bounds.size)
        if displayedDesign != newDesign {

            addChildViewController(boardViewController!)
            stackView.addArrangedSubview(boardViewController!.view)
            boardViewController!.didMove(toParentViewController: self)

            addChildViewController(historyViewController!)
            stackView.addArrangedSubview(historyViewController!.view)
            historyViewController!.didMove(toParentViewController: self)

            addChildViewController(capturedViewController!)
            stackView.addArrangedSubview(capturedViewController!.view)
            capturedViewController!.didMove(toParentViewController: self)
            
            displayedDesign = newDesign
            
        }
    }

}
