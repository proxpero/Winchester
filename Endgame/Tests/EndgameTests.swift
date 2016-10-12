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

class BoardMovementCoordinatorTests: XCTestCase {



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
            XCTAssert(c.0.isNumberRow == c.1)
        }
    }

    func testAsRowIndex() {
        XCTAssertEqual(0.asRowIndex, 2)
        XCTAssertEqual(1.asRowIndex, 3)
        XCTAssertEqual(2.asRowIndex, 5)
        XCTAssertEqual(3.asRowIndex, 6)
        XCTAssertEqual(4.asRowIndex, 8)
        XCTAssertEqual(5.asRowIndex, 9)
        XCTAssertEqual(6.asRowIndex, 11)
    }

    func testAsFullmoveIndex() {
        XCTAssertEqual(2.asFullmoveIndex, 1)
        XCTAssertEqual(3.asFullmoveIndex, 1)
        XCTAssertEqual(5.asFullmoveIndex, 2)
        XCTAssertEqual(6.asFullmoveIndex, 2)
        XCTAssertEqual(8.asFullmoveIndex, 3)
        XCTAssertEqual(9.asFullmoveIndex, 3)
        XCTAssertEqual(11.asFullmoveIndex, 4)
        XCTAssertEqual(12.asFullmoveIndex, 4)
    }


    func testItemIndex() {
        XCTAssertEqual(2.asItemIndex, 0)
        XCTAssertEqual(3.asItemIndex, 1)
        XCTAssertEqual(5.asItemIndex, 2)
        XCTAssertEqual(6.asItemIndex, 3)
        XCTAssertEqual(8.asItemIndex, 4)
    }

    func testGameHistoryRows() {
        
    }

}

class ViewHistoryConfigurationTests: XCTestCase {

    func testCellTypeForIndexAndRows() {

        let moves = "1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.b4 1-0"

        let pgn = try! PGN(parse: moves)
        let game = Game(pgn: pgn)
        game.move(to: game.startIndex)
        let coordinator = HistoryCoordinator()
        let outcome = game.outcome

        XCTAssertEqual(coordinator.rows(game)(), 13)

        XCTAssertEqual(coordinator.cellType(game)(0), .start)
        XCTAssertEqual(coordinator.cellType(game)(1), .number(1))
        XCTAssertEqual(coordinator.cellType(game)(2), .move("e4"))
        XCTAssertEqual(coordinator.cellType(game)(3), .move("e5"))
        XCTAssertEqual(coordinator.cellType(game)(4), .number(2))
        XCTAssertEqual(coordinator.cellType(game)(5), .move("Nf3"))
        XCTAssertEqual(coordinator.cellType(game)(6), .move("Nc6"))
        XCTAssertEqual(coordinator.cellType(game)(7), .number(3))
        XCTAssertEqual(coordinator.cellType(game)(8), .move("Bc4"))
        XCTAssertEqual(coordinator.cellType(game)(9), .move("Bc5"))
        XCTAssertEqual(coordinator.cellType(game)(10), .number(4))
        XCTAssertEqual(coordinator.cellType(game)(11), .move("b4"))
        XCTAssertEqual(coordinator.cellType(game)(12), .last(outcome))

    }

}
