//
//  GameViewControllerType.swift
//  Winchester
//
//  Created by Todd Olsen on 11/17/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Endgame

#if os(OSX)
    import Cocoa
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

public protocol BoardViewControllerType: ViewControllerType, BoardInteractionProtocol { }

public protocol GameViewControllerType: class, GameDelegate, BoardViewDelegateType, HistoryViewDelegate, HistoryViewDataSource {

    associatedtype B: BoardViewControllerType
    associatedtype H: HistoryViewControllerType

    var game: Game? { get }
    weak var boardViewController: B? { get }
    weak var historyViewController: H? { get }
    weak var capturedViewController: CapturedViewController? { get }

    var availableTargetsCache: [Square] { get set }

}


// MARK: - Game Delegate

extension GameViewControllerType {

    public func game(_ game: Game, didAppend item: HistoryItem, at index: Int?) {
        historyViewController?.updateCell(at: index)
    }

    public func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction) {
        guard let boardView = boardViewController?.view as? BoardView else { fatalError("Programmer Error: Expected a boardView") }
        boardView.traverse(items, in: direction)
        boardViewDidNormalizeActivity(boardView)
    }

    public func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) { }

}

// MARK: HistoryViewDelegate

extension GameViewControllerType {

    public func updateGame(with itemIndex: Int?) {
        game?.setIndex(to: itemIndex)
    }

    public func userDidSelectHistoryItem(at itemIndex: Int?) {
        game?.setIndex(to: itemIndex)
    }
    
}
