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

class MessagesViewController: MSMessagesAppViewController, GameDelegate {

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
            controller = instantiateGameCollectionViewController(with: conversation)
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

    private func instantiateGameCollectionViewController(with conversation: MSConversation) -> GameCollectionViewController {

        let interlocutorID = conversation.remoteParticipantIdentifiers
            .map { $0.uuidString }
            .reduce("") { $0 + $1 }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "GameCollectionViewController") as? GameCollectionViewController else { fatalError() }
        vc.opponent = Opponent(id: interlocutorID)
        vc.delegate = self
        return vc
    }

    private func instantiateGameViewController(with conversation: MSConversation) -> UIViewController {

        let game = Game(message: conversation.selectedMessage) ?? Game()
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

extension MessagesViewController {

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

extension MessagesViewController: GameCollectionViewControllerDelegate {
    func gameCollectionViewControllerDidSelectCreate(_ controller: GameCollectionViewController) {
        requestPresentationStyle(.expanded)
    }
}

extension UIImage {

//    convenience init?(view: UIView) {
//        UIGraphicsBeginImageContext(view.frame.size)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        view.layer.render(in: context)
//        guard
//            let image = UIGraphicsGetImageFromCurrentImageContext(),
//            let cgImage = image.cgImage
//            else { return nil }
//        UIGraphicsEndImageContext()
//        self.init(cgImage: cgImage)
//    }

    func rotated() -> UIImage {
        let imageView = UIImageView(image: self)
        imageView.transform = CGAffineTransform(rotationAngle: .pi)
        let rotated = UIImage(view: imageView)!
        return rotated
    }

    public func rotated(by degrees: CGFloat, flip: Bool = false) -> UIImage {

        let radians = degrees.toRadians

        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: radians);
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()!

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

        // Rotate the image context
        bitmap.rotate(by: radians)

        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat

        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }

        bitmap.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)

        bitmap.draw(self.cgImage!, in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
}

extension CGFloat {
    var toDegrees: CGFloat {
        return (self * 180.0) / .pi
    }
    var toRadians: CGFloat {
        return (self / 180.0) * .pi
    }
}
