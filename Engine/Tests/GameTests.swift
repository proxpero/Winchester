//
//  GameTests.swift
//  Engine
//
//  Created by Todd Olsen on 9/23/16.
//
//

import XCTest
@testable import Engine

class GameTests: XCTestCase {

    func testItemAtIndex() {

        do {
            let moves = "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6"
            let pgn = try! PGN(parse: moves)
            let game = Game(pgn: pgn)

            XCTAssertEqual(game.outcome, Outcome.undetermined)

            func test(index: Int, result: String?) {
                XCTAssertEqual(game.item(at: index)?.sanMove, result)
            }

            test(index: game.startIndex, result: Optional("e4"))
            test(index: 0, result: Optional("e4"))
            test(index: 1, result: Optional("e5"))
            test(index: 2, result: Optional("f4"))
            test(index: 3, result: Optional("exf4"))
            test(index: 4, result: Optional("Bc4"))
            test(index: 5, result: Optional("Qh4+"))
            test(index: 6, result: Optional("Kf1"))
            test(index: 7, result: Optional("b5"))
            test(index: 8, result: Optional("Bxb5"))
            test(index: 9, result: Optional("Nf6"))
            test(index: 10, result: Optional("Nf3"))
            test(index: 11, result: Optional("Qh6"))
            test(index: game.endIndex - 1, result: Optional("Qh6"))
            test(index: game.endIndex, result: nil)
        }

        do {
            let url = Bundle(for: GameTests.self).url(forResource: "fischer v fine", withExtension: "pgn")!
            let pgn = try! PGN(parse: try! String(contentsOf: url))
            let game = Game(pgn: pgn)

            for (index, item) in zip(game.startIndex..<game.endIndex, game.items) {
                XCTAssertEqual(game.item(at: index), item)
            }
        }

    }

    func testMoveToIndex() {
        let moves = "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6"
        let pgn = try! PGN(parse: moves)
        let game = Game(pgn: pgn)

        game.move(to: game.startIndex)
        XCTAssertTrue(game.history.isEmpty)

        let items1 = game.move(to: 5)
        XCTAssertEqual(items1.direction, Direction.forward(5))
        XCTAssertEqual(items1.items.map { $0.sanMove }, ["e4", "e5", "f4", "exf4", "Bc4"])

        let items2 = game.move(to: 2)
        XCTAssertEqual(items2.direction, Direction.reverse(3))
        XCTAssertEqual(items2.items.map { $0.sanMove }, ["Bc4", "exf4", "f4"])

        XCTAssertEqual(game.endIndex, 12)
        let items3 = game.move(to: 12)
        XCTAssertEqual(items3.direction, Direction.forward(10))
        XCTAssertEqual(items3.items.map { $0.sanMove }, ["f4", "exf4", "Bc4", "Qh4+", "Kf1", "b5", "Bxb5", "Nf6", "Nf3", "Qh6"])

        let items4 = game.move(to: game.startIndex)
        XCTAssertEqual(items4.direction, Direction.reverse(12))
        XCTAssertEqual(items4.items.map { $0.sanMove }, ["Qh6", "Nf3", "Nf6", "Bxb5", "b5", "Kf1", "Qh4+", "Bc4", "exf4", "f4", "e5", "e4"])

        let items5 = game.move(to: 7)
        XCTAssertEqual(items5.direction, Direction.forward(7))
        XCTAssertEqual(items5.items.map { $0.sanMove }, ["e4", "e5", "f4", "exf4", "Bc4", "Qh4+", "Kf1"])

        let items6 = game.move(to: game.endIndex)
        XCTAssertEqual(items6.direction, Direction.forward(5))
        XCTAssertEqual(items6.items.map { $0.sanMove }, ["b5", "Bxb5", "Nf6", "Nf3", "Qh6"])

        let items7 = game.move(to: game.startIndex)
        XCTAssertEqual(items7.direction, Direction.reverse(12))
        XCTAssertEqual(items7.items.map { $0.sanMove }, ["Qh6", "Nf3", "Nf6", "Bxb5", "b5", "Kf1", "Qh4+", "Bc4", "exf4", "f4", "e5", "e4"])
        XCTAssertEqual(game.currentPosition, Position())

        let items8 = game.move(to: game.endIndex)
        XCTAssertEqual(items8.direction, Direction.forward(12))
        XCTAssertEqual(items8.items.map { $0.sanMove }, ["e4", "e5", "f4", "exf4", "Bc4", "Qh4+", "Kf1", "b5", "Bxb5", "Nf6", "Nf3", "Qh6"])
    }

    func testSubscript() {

        let url = Bundle(for: GameTests.self).url(forResource: "fischer v fine", withExtension: "pgn")!
        let pgn = try! PGN(parse: try! String(contentsOf: url))
        let game = Game(pgn: pgn)

        game.map { $0.sanMove }
            .enumerated()
            .forEach { print("\($0.offset). \($0.element)") }

        XCTAssertEqual(game[11].sanMove, "exd4")
    }


}



class PGNTests: XCTestCase {

    let files = [
        String()
            + "[Event \"London\"]\n"
            + "[Site \"London\"]\n"
            + "[Date \"1851.??.??\"]\n"
            + "[EventDate \"?\"]\n"
            + "[Round \"?\"]\n"
            + "[Result \"1-0\"]\n"
            + "[White \"Adolf Anderssen\"]\n"
            + "[Black \"Kieseritzky\"]\n"
            + "[ECO \"C33\"]\n"
            + "[WhiteElo \"?\"]\n"
            + "[BlackElo \"?\"]\n"
            + "[PlyCount \"45\"]\n"
            + "\n"
            + "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6 7.d3 Nh5 8.Nh4 Qg5\n"
            + "9.Nf5 c6 10.g4 Nf6 11.Rg1 cxb5 12.h4 Qg6 13.h5 Qg5 14.Qf3 Ng8 15.Bxf4 Qf6\n"
            + "16.Nc3 Bc5 17.Nd5 Qxb2 18.Bd6 Bxg1 19. e5 Qxa1+ 20. Ke2 Na6 21.Nxg7+ Kd8\n"
            + "22.Qf6+ Nxf6 23.Be7# 1-0\n",
        String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6\n"
            + "8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4\n"
            + "15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6\n"
            + "21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+\n"
            + "26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4\n"
            + "32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4\n"
            + "38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
    ]

    func testInitialization() {
        let empty = PGN()
        XCTAssertNil(empty[PGN.Tag.white])
        XCTAssert(empty.sanMoves.isEmpty)
    }

    func testInitialization_ParseString() {
        for file in files {
            do {
                let _ = try PGN(parse: file)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testInitialization_Tag() {
        let tuple = files
            .map { try! PGN.init(parse: $0) }
            .map { ($0.tagPairs, $0.sanMoves) }
        for (tagPair, moves) in tuple {
            let game = PGN(tagPairs: tagPair, moves: moves)
            XCTAssertNotNil(game)
        }
    }

    func testInitialization_String() {
        let tuple = files
            .map { try! PGN.init(parse: $0) }
            .map { ($0.tagPairs, $0.sanMoves) }
        for (tagPair, moves) in tuple {
            var dict: [String: String] = [:]
            for pair in tagPair {
                dict[pair.key.rawValue] = pair.value
            }
            let game = PGN(tagPairs: dict, moves: moves)
            XCTAssertNotNil(game)
        }
    }

    func testParsingAndImporting() {

        let samples = [
            (files[0], "Adolf Anderssen", "Kieseritzky", 45, Outcome.win(.white)),
            (files[1], "Fischer, Robert J.", "Spassky, Boris V.", 85, Outcome.draw)
            ]

        for (file, white, black, count, outcome) in samples {

            do {
                let pgn = try PGN(parse: file)
                XCTAssertEqual(pgn[PGN.Tag.white]!, white)
                XCTAssertEqual(pgn[PGN.Tag.black]!, black)
                XCTAssertEqual(pgn.sanMoves.count, count)
                XCTAssertEqual(pgn.outcome, outcome)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testExportingTagPairs() {
        let original = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6\n"
            + "8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4\n"
            + "15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6\n"
            + "21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+\n"
            + "26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4\n"
            + "32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4\n"
            + "38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn = try! PGN(parse: original)

        let expectation = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"

        let result = pgn.exportTagPairs
        XCTAssertEqual(expectation, result)
    }

    func testExportingMoves() {

        let original = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6\n"
            + "8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4\n"
            + "15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6\n"
            + "21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+\n"
            + "26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4\n"
            + "32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4\n"
            + "38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn = try! PGN(parse: original)

        let expectation = String()
            + "e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 d6 c3 O-O h3 Nb8 d4 Nbd7 c4 c6 cxb5 axb5 Nc3 Bb7 Bg5 b4 Nb1 h6 Bh4 c5 dxe5 Nxe4 Bxe7 Qxe7 exd6 Qf6 Nbd2 Nxd6 Nc4 Nxc4 Bxc4 Nb6 Ne5 Rae8 Bxf7+ Rxf7 Nxf7 Rxe1+ Qxe1 Kxf7 Qe3 Qg5 Qxg5 hxg5 b3 Ke6 a3 Kd6 axb4 cxb4 Ra5 Nd5 f3 Bc8 Kf2 Bf5 Ra7 g6 Ra6+ Kc5 Ke1 Nf4 g3 Nxh3 Kd2 Kb5 Rd6 Kc5 Ra6 Nf2 g4 Bd3 Re6"

        for (expectation, result) in zip(pgn.sanMoves, expectation.splitByWhitespaces()) {
            XCTAssertEqual(expectation, result)
        }
        XCTAssertEqual(pgn.sanMoves.joined(separator: " "), expectation)
    }

    func testPGNExportEquality() {

        let original = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6\n"
            + "8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4\n"
            + "15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6\n"
            + "21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+\n"
            + "26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4\n"
            + "32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4\n"
            + "38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn = try! PGN(parse: original)
        let result = pgn.exported()
        print(original)
        print(result)
        XCTAssertEqual(original, result)
    }
    

}
