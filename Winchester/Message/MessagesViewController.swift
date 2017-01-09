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

class MessagesViewController: MSMessagesAppViewController {

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentViewController(for: conversation, with: presentationStyle)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }

    // Embed a new child view controller 
    private func embed(controller: UIViewController) {

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

    // MARK: Child view controller presentation

    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {

        // Determine the controller to present.
        switch presentationStyle {
        case .compact:
            embed(controller: instantiateNewGameViewController())
        case .expanded:
            embed(controller: instantiateGameViewController(with: conversation))
            if OpponentStore.defaultStore[conversation] == nil {
                setOpponentName(for: conversation)
            }
        }

    }

    private func instantiateNewGameViewController() -> NewGameViewController {
        guard let vc = storyboard?.instantiate(NewGameViewController.self) else { fatalError("") }
        vc.delegate = self
        return vc
    }

    private func instantiateGameViewController(with conversation: MSConversation) -> UIViewController {

        let game = Game(with: conversation.selectedMessage) ?? {
            let game = Game()
            if let opponent = OpponentStore.defaultStore[conversation] {
                print(opponent.name)
                game[.black] = Player(opponent: opponent)
            }
            return game
        }()

        if !game.outcome.isUndetermined {
            handleEnd(of: game, with: game.outcome)
        }

        var coordinator = GameCoordinator(for: game, isUserGame: true)
        let vc = coordinator.loadViewController()
        
        game.delegate = self
        if game.playerTurn == .black {
            vc.boardViewController?.boardView.currentOrientation = .top
        }

        return vc
        
    }

    private func setOpponentName(for conversation: MSConversation) {

        guard let key = conversation.remoteParticipantIdentifiers.first?.uuidString else {
            fatalError("Could not create an opponent key")
        }

        // Create Alert Controller
        let alertController = UIAlertController(
            title: "Enter Name",
            message: "What is your opponent's name?",
            preferredStyle: .alert
        )

        // Add textfield
        alertController.addTextField { textField in
            textField.placeholder = "Bobby Fischer"
        }

        // Configure alert action and completion handler.
        let action = UIAlertAction(title: "Submit", style: UIAlertActionStyle.default) { _ in
            guard
                let textFields = alertController.textFields,
                let textField = textFields.first,
                let name = textField.text,
                !name.isEmpty
            else { return }
            OpponentStore.defaultStore.createOpponent(name, for: key)
        }

        alertController.addAction(action)
        self.present(alertController, animated: true)
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

        guard
            let conversation = activeConversation,
            let game = gameViewController.game,
            let caption = game.lastSanMove
        else { fatalError() }

        if game[game.playerTurn].name == nil {
            if let opponent = OpponentStore.defaultStore[conversation] {
                let player = Player(name: opponent.name, kind: .human, elo: nil)
                game[game.playerTurn] = player
            }
        }

        let image = game.playerTurn.isWhite ? gameViewController.boardImage() : gameViewController.boardImage().rotated(by: 180.0)
        let message = MSMessage(image: image, caption: caption, url: game.url, session: conversation.selectedMessage?.session)

        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        dismiss()
    }

}

extension MSMessage {

    convenience init(image: UIImage, caption: String, url: URL, session: MSSession?) {

        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = caption

        self.init(session: session ?? MSSession())
        self.url = url
        self.layout = layout
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

    func game(_ game: Game, didEndWith outcome: Outcome) {
        handleEnd(of: game, with: outcome)
    }


    func handleEnd(of game: Game, with outcome: Outcome) {
        guard let conversation = activeConversation else {
            print("Error: no active conversation")
            return
        }
        guard let opponent = OpponentStore.defaultStore[conversation] else {
            fatalError("Could not get opponent")
        }
        var urls = opponent.urls
        urls.append(game.url)
        OpponentStore.defaultStore[conversation] = Opponent(name: opponent.name, urls: urls)
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

}

extension MSConversation {
    var opponentKey: String? {
        return remoteParticipantIdentifiers.first?.uuidString
    }
}

extension OpponentStore {

    func append(game: Game, for conversation: MSConversation) {
        guard let old = self[conversation] else { fatalError("Could not create Opponent form conversation") }
        self[conversation] = old.appending(url: game.url)
    }

    subscript(conversation: MSConversation) -> Opponent? {
        get {
            guard let key = conversation.opponentKey else { print("no opponent for this conversation."); return nil }
            return self[key]
        }
        set {
            guard let key = conversation.opponentKey else { return }
            self[key] = newValue
        }
    }


}
