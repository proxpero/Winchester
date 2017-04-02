//
//  GameTests.swift
//  Endgame
//
//  Created by Todd Olsen on 3/24/17.
//
//

import XCTest
@testable import Endgame

class GameTests: XCTestCase {

    func testEmptyGame() {
        let game = Game()
        XCTAssertFalse(game.isEmpty)
        XCTAssertTrue(game.count == 1)
        XCTAssertTrue(game.moveIndex == 0)
    }

    func testExecuteMove() {
        let game = Game()
        let move = Move(origin: .e2, target: .e4)
        game.execute(move: move)
        XCTAssertTrue(game.count == 2)
        XCTAssertTrue(game.moveIndex == 1)
    }

    func testExecuteSanMove() {
        let game = Game()
        let move = ["e4"]
        do {
            try game.execute(sanMoves: move)
        } catch {
            XCTFail()
        }
    }

    func testExecuteSanMoves() {
        let game = Game()
        let moves = try! "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6".moves()
        do {
            try game.execute(sanMoves: moves)
            XCTAssertEqual("rnb1kb1r/p1pp1ppp/5n1q/1B6/4Pp2/5N2/PPPP2PP/RNBQ1K1R w kq - 3 7", game.currentPosition.fen)
        } catch {
            XCTFail()
        }
    }

    func testGameIndexes() {
        let url = Bundle(for: GameTests.self).url(forResource: "fischer v fine", withExtension: "pgn")!
        let pgn = try! PGN(parse: try! String(contentsOf: url))
        let moves = pgn.sanMoves

        let game = Game()
        try! game.execute(sanMoves: moves)

        XCTAssertTrue(game.count == moves.count + 1)
        XCTAssertTrue(game.moveIndex == moves.count)

        print(game[11].history!.sanMove)

    }

    func testExecutionOfMovesArray() {
        let url = Bundle(for: GameTests.self).url(forResource: "fischer v fine", withExtension: "pgn")!
        let pgn = try! PGN(parse: try! String(contentsOf: url))
        let moves = pgn.sanMoves

        let game = Game()
        do {
            try game.execute(sanMoves: moves)
            print(game.currentPosition.ascii)
        } catch {
            XCTFail()
        }
    }

    func testExecutionOfMovesString() {
        let url = Bundle(for: GameTests.self).url(forResource: "fischer v fine", withExtension: "pgn")!
        let pgn = try! PGN(parse: try! String(contentsOf: url))
        let moves = pgn.sanMoves.joined(separator: " ")

        let game = Game()
        do {
            try game.execute(sanMoves: moves)
            print(game.currentPosition.ascii)
        } catch {
            XCTFail()
        }
    }

}
