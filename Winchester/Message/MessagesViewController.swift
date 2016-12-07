//
//  MessagesViewController.swift
//  Winchester-iMessage
//
//  Created by Todd Olsen on 11/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Messages
import Endgame
import Shared
import Shared_iOS

class MessagesViewController: MSMessagesAppViewController, GameCollectionViewControllerDataSource {

    var sections: [GameCollectionViewController.Section] = []

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentViewController(for: conversation, with: presentationStyle)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }

    // MARK: Child view controller presentation

    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {

        // Determine the controller to present.
        let controller: UIViewController
        switch presentationStyle {
        case .compact: controller = instantiateNewGameViewController()
        case .expanded: controller = instantiateGameViewController(with: conversation)
        }

        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }

        // Embed the new controller.
        addChildViewController(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controller.didMove(toParentViewController: self)

    }

    private func instantiateNewGameViewController() -> NewGameViewController {

        guard let vc = storyboard?.instantiate(NewGameViewController.self) else { fatalError("") }
        vc.delegate = self
        return vc

    }

    private func instantiateGameViewController(with conversation: MSConversation) -> UIViewController {

        let game = Game(message: conversation.selectedMessage) ?? {
            // If there's not a game in the conversation, it must be a brand new game.
            let user = Player(name: "user-id", kind: Player.Kind.human, elo: nil)
            let opponent = Player(name: conversation.remoteParticipantIdentifiers.first?.uuidString, kind: Player.Kind.human, elo: nil)
            return Game(whitePlayer: user, blackPlayer: opponent, startingPosition: Position())
        }()

        if game.playerTurn.isBlack && game.whitePlayer.name == "user-id" {
            var white = game.whitePlayer
            white.name = conversation.remoteParticipantIdentifiers.first?.uuidString
            game.whitePlayer = white
        }

        var coordinator = GameCoordinator(for: game, isUserGame: true)
        let vc = coordinator.loadViewController()
        
        game.delegate = self
        if game.playerTurn == .black {
            vc.boardViewController?.boardView.currentOrientation = .top
        }
        return vc
    }

    fileprivate func composeMessage(with image: UIImage, caption: String, url: URL, session: MSSession? = nil) -> MSMessage {

        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = caption

        let message = MSMessage(session: session ?? MSSession())
        message.url = url
        message.layout = layout

        return message
    }

    func didExecuteTurn(with gameViewController: GameViewController) {

        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        guard let game = gameViewController.game else { fatalError() }
        guard let caption = game.lastSanMove else { fatalError("This can't be the initial position") }

        if let sharedDefaults = UserDefaults(suiteName: "group.com.proxpero.winchester.shared") {
            let pgn = game.pgn.exported()
            if let opponent = conversation.remoteParticipantIdentifiers.first?.uuidString {
                var games = sharedDefaults.dictionary(forKey: opponent)
            }
        }


        if game.outcome.isUndetermined {

        }

        let image = game.playerTurn.isWhite ? gameViewController.boardImage() : gameViewController.boardImage().rotated(by: 180.0)
        let message = composeMessage(with: image, caption: caption, url: game.url, session: conversation.selectedMessage?.session)
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }

        dismiss()
        
    }

}

extension MessagesViewController: GameDelegate {

    func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction) {
        guard let gameViewController = childViewControllers.flatMap({ $0 as? GameViewController }).first else { return }
        gameViewController.game(game, didTraverse: items, in: direction)
    }

    func game(_ game: Game, didAppend item: HistoryItem, at index: Int?) {
        guard let gameViewController = childViewControllers.flatMap({ $0 as? GameViewController }).first else { return }
        gameViewController.game(game, didAppend: item, at: index)
    }

    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        guard let gameViewController = childViewControllers.flatMap({ $0 as? GameViewController }).first else { return }
        gameViewController.game(game, didExecute: move, with: capture, with: promotion)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.didExecuteTurn(with: gameViewController)
        }
        
    }

}

extension MessagesViewController: NewGameViewControllerDelegate {
    func didSelectNewGame() {
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController: GameCollectionViewControllerDelegate {

    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController) {
        requestPresentationStyle(.expanded)
    }
    
//    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController) {
//        requestPresentationStyle(.expanded)
//    }
}

