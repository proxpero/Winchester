//
//  SettingsViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/27/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class SettingsViewController: UIViewController {

    var delegate: SettingsViewDelegate?
    var dataSource: SettingsViewDataSource?

    @IBOutlet var background: UIView!

    @IBOutlet var whitePlayerLabel: UILabel!
    @IBOutlet var whiteOutcomeLabel: UILabel!
    @IBOutlet var blackPlayerLabel: UILabel!
    @IBOutlet var blackOutcomeLabel: UILabel!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var ecoLabel: UILabel!
    @IBOutlet var moveCountLabel: UILabel!
    @IBOutlet var boardImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        background.layer.backgroundColor = UIColor.white.cgColor
        background.layer.cornerRadius = 20.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        whitePlayerLabel.text = dataSource?.whitePlayerName()
        whiteOutcomeLabel.text = dataSource?.whitePlayerOutcomeName()
        blackPlayerLabel.text = dataSource?.blackPlayerName()
        blackOutcomeLabel.text = dataSource?.blackPlayerOutcomeName()
        eventLabel.text = dataSource?.eventName()
        ecoLabel.text = dataSource?.ecoName()
        moveCountLabel.text = dataSource?.movesName()
    }

    @IBAction func rotateAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.boardImage.transform = self.boardImage.transform.rotated(by: .pi * -0.5)
        }
        delegate?.settingsViewDidRotateBoard()
    }

    @IBAction func doneAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.settingsViewDidFinish()
        }
    }
}

protocol SettingsViewDataSource {
    func whitePlayerName() -> String
    func whitePlayerOutcomeName() -> String
    func blackPlayerName() -> String
    func blackPlayerOutcomeName() -> String
    func eventName() -> String
    func ecoName() -> String
    func movesName() -> String
}

protocol SettingsViewDelegate {
    var settingsViewDidRotateBoard: () -> Void { get }
    var settingsViewDidFinish: () -> Void { get }
}

struct SettingsViewCoordinator {

    struct DataSource: SettingsViewDataSource {

        private let game: Game
        init(game: Game) {
            self.game = game
        }

        func whitePlayerName() -> String {
            return game.whitePlayer.name ?? "?"
        }

        func whitePlayerOutcomeName() -> String {
            return game.outcome.description(for: .white)
        }

        func blackPlayerName() -> String {
            return game.blackPlayer.name ?? "?"
        }

        func blackPlayerOutcomeName() -> String {
            return game.outcome.description(for: .black)
        }

        func eventName() -> String {
            return ""
        }

        func ecoName() -> String {
            return "\(game.eco?.name)"
        }

        func movesName() -> String {
            return "\(game.count)"
        }

    }

    struct Delegate: SettingsViewDelegate {
        let settingsViewDidRotateBoard: () -> Void
        let settingsViewDidFinish: () -> Void
        init(settingsViewDidRotateBoard: @escaping () -> Void, settingsViewDidFinish: @escaping () -> Void) {
            self.settingsViewDidRotateBoard = settingsViewDidRotateBoard
            self.settingsViewDidFinish = settingsViewDidFinish
        }
    }

    private let game: Game

    init(with game: Game) {
        self.game = game
    }

    func start(with delegate: Delegate, navigationController: UINavigationController, orientation: @escaping () -> BoardView.Orientation) -> () -> Void {
        return {
            let vc = UIStoryboard.main.instantiate(SettingsViewController.self)
            vc.view.backgroundColor = .clear
            vc.dataSource = DataSource(game: self.game)
            vc.delegate = delegate
            vc.modalPresentationStyle = .overFullScreen
            vc.boardImage.transform = CGAffineTransform(rotationAngle: orientation().angle())
            navigationController.present(vc, animated: true)
        }
    }

}
