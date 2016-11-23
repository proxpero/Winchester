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

public protocol GameViewControllerType: class, GameDelegate, BoardViewDelegateType, HistoryViewDelegate, HistoryViewDataSource {

    associatedtype B: BoardViewControllerType
    associatedtype H: HistoryViewControllerType

    var game: Game? { get }
    weak var boardViewController: B? { get }
    weak var historyViewController: H? { get }
    weak var capturedPiecesViewController: CapturedPiecesViewController? { get }

    var availableTargetsCache: [Square] { get set }

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
