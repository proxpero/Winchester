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

protocol GameViewControllerType: class, GameDelegate, BoardViewDelegateType, HistoryViewDelegate, HistoryViewDataSource {

    var game: Game? { get }
    weak var boardViewController: BoardViewController? { get }
    weak var historyViewController: HistoryViewController? { get }
    weak var capturedViewController: CapturedViewController? { get }

    var availableTargetsCache: [Square] { get set }

}


// MARK: - Game Delegate

extension GameViewControllerType {

    func game(_ game: Game, didAppend item: HistoryItem, at index: Int?) {
        historyViewController?.updateCell(at: index)
    }

    func game(_ game: Game, didTraverse items: [HistoryItem], in direction: Direction) {
        guard let boardView = boardViewController?.view as? BoardView else { fatalError("Programmer Error: Expected a boardView") }
        boardView.traverse(items, in: direction)
        boardViewDidNormalizeActivity(boardView)
    }

    func game(_ game: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) { }

}

// MARK: HistoryViewDelegate

extension GameViewControllerType {

    func updateGame(with itemIndex: Int?) {
        game?.setIndex(to: itemIndex)
    }

    func userDidSelectHistoryItem(at itemIndex: Int?) {
        game?.setIndex(to: itemIndex)
    }
    
}

fileprivate extension Selector {
    static let handleSwipe = #selector(HistoryViewController.handleSwipe(_:))
}
