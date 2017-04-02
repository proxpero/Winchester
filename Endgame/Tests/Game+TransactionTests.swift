//
//  Game+TransactionTests.swift
//  Endgame
//
//  Created by Todd Olsen on 3/28/17.
//
//

import XCTest
@testable import Endgame

class TestDelegate: GameDelegate {

    var events: [Game.Event]!
    var direction: Game.Event.Direction!
    var transactions: Set<Transaction>!

    func game(_ game: Game, didTraverse events: ArraySlice<Game.Event>, in direction: Game.Event.Direction, with transactions: Set<Transaction>) {

        self.events = Array(events)
        self.direction = direction
        self.transactions = transactions

    }

}


class Game_TransactionTests: XCTestCase {

    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        game = Game()
        delegate = TestDelegate()
    }

    override func tearDown() {
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testMerge_0() {

        let moves = try! "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6".moves()
        try! game.execute(sanMoves: moves)
        game.moveIndex = 0

        var initialBoard = game.currentPosition.board
        game.delegate = delegate

        game.redoAll()

        XCTAssertEqual(delegate!.events.count, 12)
        XCTAssertEqual(delegate!.direction, .redo)
        XCTAssertEqual(delegate!.transactions.count, 9)

        let resultingBoard = game.currentPosition.board
        initialBoard = initialBoard.execute(transactions: delegate!.transactions)

        XCTAssertEqual(initialBoard, resultingBoard)

    }

    func testMerge_1() {

        let moves = try! "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6".moves()
        try! game.execute(sanMoves: moves)

        var initialBoard = game.currentPosition.board
        print(initialBoard.ascii)
        game.delegate = delegate

        game.undoAll()

        XCTAssertEqual(delegate!.events.count, 12)
        XCTAssertEqual(delegate!.direction, .undo)
        XCTAssertEqual(delegate!.transactions.count, 9)

        let resultingBoard = game.currentPosition.board
        print(resultingBoard.ascii)
        initialBoard = initialBoard.execute(transactions: delegate!.transactions)
        print(initialBoard.ascii)

        XCTAssertEqual(initialBoard, resultingBoard)
        
    }

    func testMerge_2() {

        let moves = try! "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4 Bxb4 5. c3 Ba5 6. d4 exd4 7. O-O dxc3 8. Qb3 Qe7 9. Nxc3 Nf6 10. Nd5 Nxd5 11. exd5 Ne5 12. Nxe5 Qxe5 13. Bb2 Qg5 14. h4 Qxh4 15. Bxg7 Rg8 16. Rfe1+ Kd8 17. Qg3".moves()
        try! game.execute(sanMoves: moves)
        game.moveIndex = 0

        var initialBoard = game.currentPosition.board
        game.delegate = delegate

        game.redoAll()

        XCTAssertEqual(delegate!.events.count, 33)
        XCTAssertEqual(delegate!.direction, .redo)
        XCTAssertEqual(delegate!.transactions.count, 20)

        let resultingBoard = game.currentPosition.board
        initialBoard = initialBoard.execute(transactions: delegate!.transactions)

        XCTAssertEqual(initialBoard, resultingBoard)
        
    }


}

