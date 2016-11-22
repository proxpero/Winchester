//
//  SettingsViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/27/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame
import Shared

final class SettingsViewController: UIViewController {

    var delegate: SettingsViewDelegate?
    var dataSource: SettingsViewDataSource?

    @IBOutlet var background: UIView!

    @IBOutlet var whitePlayerLabel: UITextField!
    @IBOutlet var blackPlayerLabel: UITextField!
    @IBOutlet var whiteOutcomeLabel: UILabel!
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
        whitePlayerLabel.text = dataSource?.whitePlayerName
        whiteOutcomeLabel.text = dataSource?.whitePlayerOutcome
        blackPlayerLabel.text = dataSource?.blackPlayerName
        blackOutcomeLabel.text = dataSource?.blackPlayerOutcome
        eventLabel.text = dataSource?.event
        ecoLabel.text = dataSource?.eco
        moveCountLabel.text = dataSource?.moves
    }

    @IBAction func rotateAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.boardImage.transform = self.boardImage.transform.rotated(by: .pi * -0.5)
        }
        delegate?.settingsViewDidRotateBoard()
    }

    @IBAction func doneAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

protocol SettingsViewDataSource {
    weak var game: Game? { get }
    var whitePlayerName: String { get set }
    var whitePlayerOutcome: String { get }
    var blackPlayerName: String { get set }
    var blackPlayerOutcome: String { get }
    var event: String { get set }
    var eco: String { get }
    var moves: String { get }
}

extension SettingsViewDataSource {

}

protocol SettingsViewDelegate {
    var settingsViewDidRotateBoard: () -> Void { get }
}

struct SettingsViewCoordinator {

    struct DataSource: SettingsViewDataSource {

        weak var game: Game?
        init(game: Game) {
            self.game = game
        }

        var whitePlayerName: String {
            get {
                return game?.whitePlayer.name ?? "?"
            }
            set {
                game?.whitePlayer.name = newValue
            }
        }

        var whitePlayerOutcome: String {
            get {
                guard let game = game else { return "" }
                return game.outcome.description(for: .white)
            }
        }

        var blackPlayerName: String {
            get {
                return game?.blackPlayer.name ?? "?"
            }
            set {
                game?.blackPlayer.name = newValue
            }
        }

        var blackPlayerOutcome: String {
            get {
                guard let game = game else { return "" }
                return game.outcome.description(for: .black)
            }
        }

        var event: String {
            get {
                return ""
            }
            set {
                // game does not support event property
            }
        }

        var eco: String {
            return game?.eco?.name ?? ""
        }

        var moves: String {
            guard let game = game else { return "0" }
            return "\(game.count)"
        }

    }

    struct Delegate: SettingsViewDelegate {
        
        weak var game: Game?

        let settingsViewDidRotateBoard: () -> Void

        init(game: Game, settingsViewDidRotateBoard: @escaping () -> Void) {
            self.game = game
            self.settingsViewDidRotateBoard = settingsViewDidRotateBoard
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
//            vc.boardImage.transform = CGAffineTransform(rotationAngle: orientation().angle())
            navigationController.present(vc, animated: true)
        }
    }

}
