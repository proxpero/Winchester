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

public final class GameViewController: UIViewController {

    var userActivityCoordinator: UserActivityCoordinator!

    var didTapSettingsButton: () -> () = { }
    var didTapBackButton: () -> () = { }
    var presentScene: () -> Void  =  { }

    @IBOutlet var stackView: UIStackView!

    var titleViewController: TitleViewController!
    var boardViewController: BoardViewController!
    var historyViewController: HistoryViewController!
    var captureViewController: CaptureViewController!

    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        didTapSettingsButton()
    }

    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.didTapBackButton()
    }

    var displayedDesign: Design? = nil

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let newDesign = Design(size: view.bounds.size)
        if displayedDesign != newDesign {

            addChildViewController(titleViewController)
            stackView.addArrangedSubview(titleViewController.view)
            titleViewController.didMove(toParentViewController: self)

            addChildViewController(boardViewController)
            stackView.addArrangedSubview(boardViewController.view)
            boardViewController.didMove(toParentViewController: self)

            addChildViewController(historyViewController)
            stackView.addArrangedSubview(historyViewController.view)
            historyViewController.didMove(toParentViewController: self)

            addChildViewController(captureViewController)
            stackView.addArrangedSubview(captureViewController.view)
            captureViewController.didMove(toParentViewController: self)

            presentScene()
            displayedDesign = newDesign
            
        }
    }

}
