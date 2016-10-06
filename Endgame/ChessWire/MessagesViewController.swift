//
//  MessagesViewController.swift
//  ChessWire
//
//  Created by Todd Olsen on 9/15/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Messages
import Engine

class MessagesViewController: MSMessagesAppViewController {
    // MARK: Properties

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)

        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }

    // MARK: Child view controller presentation

    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Determine the controller to present.
        let controller: UIViewController
        if presentationStyle == .compact {
            // Show a list of previous games.
            controller = instantiateGamesListViewController()
        } else {
            /*
             Create a `Game` from the conversation's `selectedMessage` or
             create a new `Game` if there isn't data associated with the message.
             */
            let game = Game(message: conversation.selectedMessage) ?? Game()

            controller = instantiateGameViewController(with: game)
        }

        // Remove any existing child controller.
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

    private func instantiateGamesListViewController() -> ChessGamesListViewController {
        // Instantiate a 'ChessGamesListViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: ChessGamesListViewController.storyboardIdentifier) as? ChessGamesListViewController else {
            fatalError("Unable to instantiate an ChessGamesListViewController from the storyboard")
        }

        controller.delegate = self

        return controller
    }

    private func instantiateGameViewController(with game: Game) -> ChessGameViewController {
        return ChessGameViewController(nibName: nil, bundle: nil)
    }

}

extension MessagesViewController: ChessGamesListViewControllerDelegate {
    func gamesListViewControllerDidSelectAdd(_ controller: ChessGamesListViewController) {
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController: ChessGameViewControllerDelegate {
    internal func chessGameViewController(didExecute move: Move) {
//        <#code#>
    }

    func chessGameViewController(_ controller: ChessGameViewController, didExecute move: Move) {

    }
}

extension PGN {
    init?(message: MSMessage?) {
        guard
            let messageURL = message?.url,
            let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems
        else { return nil }

        let sanString = queryItems.filter({ $0.name == "moves" }).first?.value ?? ""
        do { try self.init(parse: sanString) } catch { return nil }
    }

    var queryItem: URLQueryItem {
        return URLQueryItem(name: "moves", value: "sanMoves")
    }
}

extension Game {
    convenience init?(message: MSMessage?) {
        guard let pgn = PGN(message: message) else { return nil }
        self.init(pgn: pgn)
    }

    convenience init?(queryItems: [URLQueryItem]) {
        let sanString = queryItems.filter({ $0.name == "moves" }).first?.value ?? ""
        do {
            let pgn = try PGN(parse: sanString)
            self.init(pgn: pgn)
        } catch {
            return nil
        }
    }
    var queryItem: URLQueryItem {
        return pgn.queryItem
    }
}
