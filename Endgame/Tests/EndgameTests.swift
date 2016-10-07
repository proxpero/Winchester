//
//  EndgameTests.swift
//  Endgame
//
//  Created by Todd Olsen on 8/14/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import XCTest
import Messages
@testable import Engine
@testable import Endgame

class EndgameTests: XCTestCase {

    func testTests() {
        XCTAssert(true)
    }

    func testPGNInitWithMessage() {
        let message = MSMessage()



    }


}

class GameViewControllerTests: XCTestCase {


}

class HistoryViewControllerTests: XCTestCase {

    func testIsNumberRow() {

        let cases = [
            (0, false),
            (1, true),
            (2, false),
            (3, false),
            (4, true),
            (5, false),
            (6, false),
            (7, true),
            (8, false),
            (9, false),
            (10, true),
            (11, false)
        ]

        for c in cases {
            XCTAssert(c.0.isNumberRow() == c.1)
        }
    }

    func testMoveIndex() {
        XCTAssertEqual(2.moveIndex(), 1)
        XCTAssertEqual(3.moveIndex(), 2)
        XCTAssertEqual(5.moveIndex(), 3)
        XCTAssertEqual(6.moveIndex(), 4)
        XCTAssertEqual(8.moveIndex(), 5)
    }

}

class ViewHistoryConfigurationTests: XCTestCase {

    func testCellTypeForIndex() {

        let moves = "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4 1-0"

        let pgn = try! PGN(parse: moves)
        let game = Game(pgn: pgn)
        game.move(to: game.startIndex)
        let historyVC = HistoryViewController()
        let configuration = HistoryViewConfiguration(game: game, historyViewController: historyVC, moveSelectionHandler: { _ in })

        XCTAssertEqual(historyVC.rows, 12)
        XCTAssertEqual(configuration.cellType(for: 0), .start)
        XCTAssertEqual(configuration.cellType(for: 1), .number(1))
        XCTAssertEqual(configuration.cellType(for: 2), .move("e4"))
        XCTAssertEqual(configuration.cellType(for: 3), .move("e5"))
        XCTAssertEqual(configuration.cellType(for: 4), .number(2))
        XCTAssertEqual(configuration.cellType(for: 5), .move("Nf3"))

    }

    func testMoveSelectionHandler() {
        let moves = "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6"
        let pgn = try! PGN(parse: moves)
        let game = Game(pgn: pgn)
        let historyVC = HistoryViewController()
        let configuration = HistoryViewConfiguration(
            game: game,
            historyViewController: historyVC,
            moveSelectionHandler: { index in

            }
        )

    }
}
