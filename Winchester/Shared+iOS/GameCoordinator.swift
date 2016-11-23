//
//  GameCoordinator.swift
//  Winchester
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit
import Endgame
import Shared

public struct GameCoordinator {

    private let navigationController: UINavigationController
    private let game: Game
    private let isUserGame: Bool
//    private let settingsViewCoordinator: SettingsViewCoordinator

    public init(for game: Game, with navigationController: UINavigationController, isUserGame: Bool = false) {
        self.navigationController = navigationController
        self.game = game
        self.isUserGame = isUserGame
//        self.settingsViewCoordinator = SettingsViewCoordinator(with: game)
    }

    public mutating func start() {

        let vc = UIStoryboard.main.instantiate(GameViewController.self)
        vc.game = game
        game.delegate = vc

        // MARK: BoardViewController

        do {

            let boardViewController = UIStoryboard.main.instantiate(BoardViewController.self)
            boardViewController.boardView.updatePieces(with: game.currentPosition.board)
            boardViewController.delegate = vc
            vc.boardViewController = boardViewController

        }
        
        // MARK: HistoryViewController

        do {

            let historyViewController = UIStoryboard.main.instantiate(HistoryViewController.self)
            historyViewController.delegate = vc
            historyViewController.dataSource = vc
            let currentIndexPath = vc.indexPath(for: game.currentIndex)
            historyViewController.collectionView?.selectItem(at: currentIndexPath, animated: false, scrollPosition: .centeredHorizontally)
            vc.historyViewController = historyViewController

            #if os(iOS) || os(tvOS)
                for direction in [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right] {
                    vc.view.addSwipeGestureRecognizer(
                        target: historyViewController,
                        action: .handleSwipe,
                        direction: direction
                    )
                }
            #endif

        }

        vc.capturedPiecesViewController = UIStoryboard.main.instantiate(CapturedPiecesViewController.self)
        if let capturedView = vc.capturedPiecesViewController?.view as? CapturedPiecesView {
            vc.boardViewController?.boardView.pieceCapturingViewDelegate = capturedView
        }

        vc.navigationItem.title = game.outcome.description

//        let settingsViewDelegate = SettingsViewCoordinator.Delegate(
//            game: game,
//            settingsViewDidRotateBoard: vc.boardViewController!.boardView.rotateView
//        )
//        vc.didTapSettingsButton = settingsViewCoordinator.start(
//            with: settingsViewDelegate,
//            navigationController: navigationController,
//            orientation: { vc.boardViewController!.boardView.currentOrientation }
//        )

        vc.didTapBackButton = backButtonHandler
        navigationController.pushViewController(vc, animated: true)

    }

    func backButtonHandler() {
        save()
        guard let vc = navigationController.popViewController(animated: true) as? GameViewController else { return }
        vc.boardViewController = nil
        if isUserGame {
            save()
        }
        
    }

    func save() {
        let pgn = game.pgn.exported()
        var pgns = UserDefaults.standard.array(forKey: "user-games") as? [String] ?? [String]()
        pgns.append(pgn)
        UserDefaults.standard.set(pgns, forKey: "user-games")
    }

}

fileprivate extension Selector {
    static let handleSwipe = #selector(HistoryViewController.handleSwipe(_:))
}

extension UIStoryboard {

    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    func instantiate<A: UIViewController>(_ type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }

}

