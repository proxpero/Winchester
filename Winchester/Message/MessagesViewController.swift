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

class MessagesViewController: MSMessagesAppViewController, GameViewControllerDelegate {

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
        case .compact:
            controller = instantiateChessGamesViewController(with: conversation)
        case .expanded:
            controller = instantiateGameViewController(with: conversation)
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

    private func instantiateChessGamesViewController(with conversation: MSConversation) -> ChessGamesViewController {

        let interlocutorID = conversation.remoteParticipantIdentifiers
            .map { $0.uuidString }
            .reduce("") { $0 + $1 }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChessGamesViewController") as? ChessGamesViewController else { fatalError() }
        vc.opponent = Opponent(id: interlocutorID)
        vc.delegate = self
        return vc
    }

    private func instantiateGameViewController(with conversation: MSConversation) -> UIViewController {
        let game = Game(message: conversation.selectedMessage) ?? Game()

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { fatalError() }

        vc.game = game
        game.delegate = vc
        vc.delegate = self

        // MARK: BoardViewController

        do {

            let boardViewController = storyboard!.instantiate(BoardViewController.self)
            boardViewController.boardView.updatePieces(with: game.currentPosition.board)
            boardViewController.delegate = vc
            vc.boardViewController = boardViewController

            if game.playerTurn == .black {
                boardViewController.boardView.currentOrientation = .top
            }

        }

        // MARK: HistoryViewController

        do {

            let historyViewController = storyboard!.instantiate(HistoryViewController.self)
            historyViewController.delegate = vc
            historyViewController.dataSource = vc
            let currentIndexPath = vc.indexPath(for: game.currentIndex)
            historyViewController.collectionView?.selectItem(at: currentIndexPath, animated: false, scrollPosition: .centeredHorizontally)
            vc.historyViewController = historyViewController

            for direction in [UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right] {
                vc.view.addSwipeGestureRecognizer(
                    target: historyViewController,
                    action: .handleSwipe,
                    direction: direction
                )
            }

        }

        vc.capturedViewController = storyboard!.instantiate(CapturedViewController.self)
        if let capturedView = vc.capturedViewController?.view as? CapturedView {
            vc.boardViewController?.boardView.capturingViewDelegate = capturedView
        }

        vc.navigationItem.title = game.outcome.description

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

    func didExecuteTurn(with boardImage: UIImage, gameViewController: GameViewController) {

        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        guard let game = gameViewController.game else { fatalError() }
        guard let caption = game.lastSanMove else { fatalError("This can't be the initial position") }

        let message = composeMessage(with: boardImage, caption: caption, url: game.url, session: conversation.selectedMessage?.session)
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        dismiss()
    }


    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    

    


}

extension MessagesViewController: ChessGamesViewControllerDelegate {
    func chessGamesViewControllerDidSelectCreate(_ controller: ChessGamesViewController) {
        requestPresentationStyle(.expanded)
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

extension UISwipeGestureRecognizer {
    public convenience init(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection) {
        self.init(target: target, action: action)
        self.direction = direction
    }
}

extension UIView {
    public func addSwipeGestureRecognizer(target: Any?, action: Selector?, direction: UISwipeGestureRecognizerDirection = .right ) {
        let swipe = UISwipeGestureRecognizer(target: target, action: action, direction: direction)
        addGestureRecognizer(swipe)
    }
}

