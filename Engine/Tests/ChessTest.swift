//
//  ChessTest.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

import XCTest
@testable import Engine

let sampleFens = [
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    "1k1r4/pp1b1R2/3q2pp/4p3/2B5/4Q3/PPP2B2/2K5 b - - 0 1",
    "r1b1k3/p2p1Nr1/n2b3p/3pp1pP/2BB1p2/P3P2R/Q1P3P1/R3K1N1 b Qq - 0 1",
    "r1b1k2r/pp1n1ppp/2p1p3/q5B1/1b1P4/P1n1PN2/1P1Q1PPP/2R1KB1R b Kkq - 3 10",
    "5rk1/p5pp/2p3p1/1p1pR3/3P2P1/2N5/PP3n2/2KB4 w - - 1 26",
    "rnbq1rk1/ppp3pp/3bpn2/3p1p2/2PP4/2NBPN2/PP3PPP/R1BQK2R w KQ - 3 7",
    "8/5R2/8/r2KB3/6k1/8/8/8 w - - 19 79",
    "rnbqkbnr/pppppp2/7p/6pP/8/8/PPPPPPP1/RNBQKBNR w KQkq g6 0 3",
    "rnbqkbnr/pp1ppppp/8/8/2pP4/2P2N2/PP2PPPP/RNBQKB1R b KQkq d3 0 3",
    "rnbqkbnr/pp1ppppp/2p5/8/6P1/2P5/PP1PPP1P/RNBQKBNR b KQkq - 0 1",
    "rnb1kbnr/ppq1pppp/2pp4/8/6P1/2P5/PP1PPPBP/RNBQK1NR w KQkq - 0 1",
    "rn2kbnr/p1q1ppp1/1ppp3p/8/4B1b1/2P4P/PPQPPP2/RNB1K1NR w KQkq - 0 1",
    "rnkq1bnr/p3ppp1/1ppp3p/3B4/6b1/2PQ3P/PP1PPP2/RNB1K1NR w KQ - 0 1",
    "rn1q1bnr/3kppp1/2pp3p/pp6/1P2b3/2PQ1N1P/P2PPPB1/RNB1K2R w KQ - 0 1",
    "rnkq1bnr/4pp2/2pQ2pp/pp6/1P5N/2P4P/P2PPP2/RNB1KB1b w Q - 0 1",
    "rn3b1r/1kq1p3/2pQ1npp/Pp6/4b3/2PPP2P/P4P2/RNB1KB2 w Q - 0 1",
    "r4br1/8/k1p2npp/Ppn1p3/P7/2PPP1qP/4bPQ1/RNB1KB2 w Q - 0 1",
    "rnbqk1nr/p2p3p/1p5b/2pPppp1/8/P7/1PPQPPPP/RNB1KBNR w KQkq c6 0 1",
    "rnb1k2r/pp1p1p1p/1q1P4/2pnpPp1/6P1/2N5/PP1BP2P/R2QKBNR w KQkq e6 0 1",
    "1n4kr/2B4p/2nb2b1/ppp5/P1PpP3/3P4/5K2/1N1R4 b - c3 0 1",
    "r2n3r/1bNk2pp/6P1/pP3p2/3pPqnP/1P1P1p1R/2P3B1/Q1B1bKN1 b - e3 0 1"
]


class ChessTest: XCTestCase {

    // MARK: Game.Position Tests:

    func testFenInitialization() {

//        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
//        XCTAssertEqual(Game.Position(fen: fen), Game.Position())
//        XCTAssertEqual(Game.Position().fen(), fen)

    }

    // MARK: Game.Outcome Tests:

    func testOutcome() {

        let ww = "1-0"
        let bw = "0-1"
        let dr = "1/2-1/2"

        let whiteWin = Outcome(ww)
        let blackWin = Outcome(bw)
        let draw = Outcome(dr)
        XCTAssertNotNil(whiteWin)
        XCTAssertTrue(whiteWin!.isWin)
        XCTAssertFalse(whiteWin!.isDraw)
        XCTAssertTrue(blackWin!.isWin)
        XCTAssertFalse(blackWin!.isDraw)
        XCTAssertFalse(draw!.isWin)
        XCTAssertTrue(draw!.isDraw)

        XCTAssert(whiteWin!.value(for: .white) == 1.0)
        XCTAssert(whiteWin!.value(for: .black) == 0.0)
        XCTAssert(blackWin!.value(for: .white) == 0.0)
        XCTAssert(blackWin!.value(for: .black) == 1.0)
        XCTAssert(draw!.value(for: .white) == 0.5)
        XCTAssert(draw!.value(for: .black) == 0.5)

        XCTAssert(whiteWin!.description == ww)
        XCTAssert(blackWin!.description == bw)
        XCTAssert(draw!.description == dr)

    }

    // MARK: Game Computed properties:

    func testEnPassantTarget() {

        let game = Game()
        do {
            print(game.currentPosition.fen)
            try game.execute(move: Move(origin: .c2, target: .c4))
            print(game.currentPosition.fen)
            try game.execute(move: Move(origin: .c7, target: .c6))
            print(game.currentPosition.fen)
            try game.execute(move: Move(origin: .c4, target: .c5))
            print(game.currentPosition.fen)
            try game.execute(move: Move(origin: .d7, target: .d5))
            print(game.currentPosition.fen)
            try game.execute(move: Move(origin: .c5, target: .d6))
            print(game.currentPosition.fen)
        } catch {
            XCTFail()
        }

    }

    // MARK: Game Attacks

    func testIsKingInCheck() {

        let fens = [
            "k7/8/q6K/8/8/8/8/8",
            "8/5r2/4K1q1/4p3/3k4/8/8/8",
            "8/8/4K1q1/8/3k4/8/8/8",
            "8/5r2/4K1q1/8/3k4/8/8/8",
            "8/5r2/4K1q1/4p3/3k4/8/8/8",
            "7n/5p2/4K3/4p3/3k4/8/8/8",
            "k/8/8/8/3K1q2/8/8/8",
            "8/5r2/5Kq1/8/3k4/8/8/8",
            "8/5r2/5Kq1/4p3/3k4/8/8/8"
        ]

        for fen in fens {
            let board = Board(fen: fen)!
            XCTAssert(board.isKingInCheck(for: .white), fen)
        }

        // TODO: Check for false positives.

    }

    func testIsKingInMultipleCheck() {
        XCTFail()
    }


    func testMove_PawnPush_Valid() {
//        let game = Game()
//        let move = Move(origin: .e2, target: .e4)
//        do {
//            try game.execute(move: move)
//            print(game.board.ascii)
//        } catch {
//            XCTFail()
//        }
    }

    func testMove_PawnPush_Invalid() {
//        let game = Game()
//        let move = Move(origin: .e2, target: .e5)
//        do {
//            try game.execute(move: move)
//            XCTFail()
//        } catch {
//            print(game.board.ascii)
//        }
    }

//    func testMove_Castle_KingsideWhite_Valid() {
//        let fen = "R2K4/8/8/8/8/8/8/8 w K - 0 1"
//        let game = Game
//    }

    func testAvailableMoves() {
        XCTFail()
    }

    func testBitboardForPieceAtSquare() {
        XCTFail()
    }

    func testMovesForPieceAtSquare() {
        XCTFail()
    }

    func testIsLegalMove() {
        XCTFail()
    }

    // MARK: Execute Move

    func testUncheckedMovePromotion() {
        XCTFail()
    }

    func testExecuteMovePromotion() {
        XCTFail()
    }

    // MARK: Game Move and Undo History

    func testMoveToUndo() {
        XCTFail()
    }

    func testMoveToRedo() {
        XCTFail()
    }

    func testUndoMove() {
        XCTFail()
    }

    func testRedoMove() {
        XCTFail()
    }

    // MARK: Game PGN




    // MARK: Player Tests:


    // MARK: Board Tests:



    // MARK: Board Attacks:


    // MARK: Bitboard Tests:



    // MARK: Ascii Tests:



    // MARK: Piece Tests:



    // MARK: Piece Tests:



    // MARK: Color Tests:



    // MARK: File Tests:

    func testFileIndex() {

        XCTAssertEqual(File.d.index, 3)

    }

    func testFileFromCharacter() {
        for u in 65...72 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u)!)))
        }
        for u in 97...104 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u)!)))
        }
    }

    func testAllFiles() {
        XCTAssertEqual(File.all, ["a", "b", "c", "d", "e", "f", "g", "h"])
    }

    func testFileTo() {

        XCTAssertEqual(File.a.to(.h), File.all)
        XCTAssertEqual(File.a.to(.a), [File.a])

    }

    func testFileBetween() {

        XCTAssertEqual(File.c.between(.f), [.d, .e])
        XCTAssertEqual(File.c.between(.d), [])
        XCTAssertEqual(File.c.between(.c), [])
        
    }

    func testFileOpposite() {

        let all = File.all
        let reversed = all.reversed()
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }

    }

    func testFileAdvancedBy() {

        XCTAssertEqual(File.d.advanced(by: 2), File.f)

    }

    func testFilePrevious() {

        XCTAssertEqual(File.d.previous()!, File.c)

    }

    func testFileNext() {

        XCTAssertEqual(File.d.next()!, File.e)

    }

    // MARK: Rank Tests:

    func testRankIndex() {

        XCTAssertEqual(Rank.five.index, 4)

    }

    func testRankFromNumber() {
        for n in 1...8 {
            XCTAssertNotNil(Rank(n))
        }
    }

    func testAllRanks() {
        XCTAssertEqual(Rank.all, [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func testRankTo() {

        XCTAssertEqual(Rank.one.to(.eight), Rank.all)
        XCTAssertEqual(Rank.one.to(.one), [Rank.one])

    }

    func testRankBetween() {

        XCTAssertEqual(Rank.two.between(.five), [.three, .four])
        XCTAssertEqual(Rank.two.between(.three), [])
        XCTAssertEqual(Rank.two.between(.two), [])
        
    }

    func testRankOpposite() {

        let all = Rank.all
        let reversed = all.reversed()
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }

    }

    func testRankAdvancedBy() {

        XCTAssertEqual(Rank.four.advanced(by: 3)!, Rank.seven)
        XCTAssertEqual(Rank.four.advanced(by: 3, for: .black)!, Rank.one)
        
    }

    func testRankPrevious() {

        XCTAssertEqual(Rank.four.previous()!, Rank.three)

    }

    func testRankNext() {

        XCTAssertEqual(Rank.four.next()!, Rank.five)

    }

    // MARK:

    // MARK: Square Tests:

    // MARK: Move Tests:

    func testMoveEquality() {

        let move = Move(origin: .a1, target: .c3)
        XCTAssertEqual(move, move)
        XCTAssertEqual(move, Move(origin: .a1, target: .c3))
        XCTAssertNotEqual(move, Move(origin: .a1, target: .b1))

    }

    func testMoveRotation() {

        let move = Move(origin: .a1, target: .c6)
        let rotated = move.rotated()
        XCTAssertEqual(rotated.origin, Square.h8)
        XCTAssertEqual(rotated.target, Square.f3)

    }

    func testMoveProperties() {

        let move1 = Move(origin: .e2, target: .e4)
        XCTAssertEqual(move1.rankChange, 2)
        XCTAssertEqual(move1.fileChange, 0)
        XCTAssertTrue(move1.isChange)
        XCTAssertFalse(move1.isDiagonal)
        XCTAssertFalse(move1.isHorizontal)
        XCTAssertTrue(move1.isVertical)
        XCTAssertTrue(move1.isAxial)
        XCTAssertFalse(move1.isLeftward)
        XCTAssertFalse(move1.isRightward)
        XCTAssertFalse(move1.isDownward)
        XCTAssertTrue(move1.isUpward)
        XCTAssertFalse(move1.isKnightJump)
        XCTAssertNil(move1.fileDirection)
        XCTAssertEqual(move1.rankDirection!, Rank.Direction.up)
        XCTAssertFalse(move1.isCastle())
        XCTAssertEqual(move1.reversed(), Move(origin: .e4, target: .e2))

        let move2 = Move(origin: .e2, target: .b2)
        XCTAssertEqual(move2.rankChange, 0)
        XCTAssertEqual(move2.fileChange, -3)
        XCTAssertTrue(move2.isChange)
        XCTAssertFalse(move2.isDiagonal)
        XCTAssertTrue(move2.isHorizontal)
        XCTAssertFalse(move2.isVertical)
        XCTAssertTrue(move2.isAxial)
        XCTAssertTrue(move2.isLeftward)
        XCTAssertFalse(move2.isRightward)
        XCTAssertFalse(move2.isDownward)
        XCTAssertFalse(move2.isUpward)
        XCTAssertFalse(move2.isKnightJump)
        XCTAssertEqual(move2.fileDirection!, File.Direction.left)
        XCTAssertNil(move2.rankDirection)
        XCTAssertFalse(move2.isCastle())
        XCTAssertEqual(move2.reversed(), Move(origin: .b2, target: .e2))

        let move3 = Move(origin: .g6, target: .e5)
        XCTAssertEqual(move3.rankChange, -1)
        XCTAssertEqual(move3.fileChange, -2)
        XCTAssertTrue(move3.isChange)
        XCTAssertFalse(move3.isDiagonal)
        XCTAssertFalse(move3.isHorizontal)
        XCTAssertFalse(move3.isVertical)
        XCTAssertFalse(move3.isAxial)
        XCTAssertTrue(move3.isLeftward)
        XCTAssertFalse(move3.isRightward)
        XCTAssertTrue(move3.isDownward)
        XCTAssertFalse(move3.isUpward)
        XCTAssertTrue(move3.isKnightJump)
        XCTAssertEqual(move3.fileDirection!, File.Direction.left)
        XCTAssertEqual(move3.rankDirection!, Rank.Direction.down)
        XCTAssertFalse(move3.isCastle())
        XCTAssertEqual(move3.reversed(), Move(origin: .e5, target: .g6))

        let move4 = Move(castle: .black, side: .kingside)
        XCTAssertTrue(move4.isCastle())
        XCTAssertEqual(move4.origin, .e8)
        XCTAssertEqual(move4.target, .g8)

    }

    // MARK: Variant Tests:

    // MARK: CastlingRights Tests:

    // MARK: PGN Tests:



    func testPGNParsingAndExporting() {

        let file1 = String()
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
            + "22.Qf6+ Nxf6 23.Be7# 1-0\n"

        let file2 = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let files = [
            (file1, "Adolf Anderssen", "Kieseritzky", 45, Outcome.win(.white)),
            (file2, "Fischer, Robert J.", "Spassky, Boris V.", 85, Outcome.draw)
        ]

        for (file, white, black, count, outcome) in files {

            do {
                let pgn = try PGN(parse: file)
                XCTAssertEqual(pgn[PGN.Tag.white]!, white)
                XCTAssertEqual(pgn[PGN.Tag.black]!, black)
                XCTAssertEqual(pgn.sanMoves.count, count)
                XCTAssertEqual(pgn.outcome!, outcome)
//                XCTAssertEqual(pgn.exported(), file)

            } catch {
                XCTFail(error.localizedDescription)
            }

        }

    }



    func testPGNExportMovesEquality() {
        let original = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
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
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn = try! PGN(parse: original)
        let result = pgn.exported()
        XCTAssertEqual(original, result)
    }

    func testGameInitWithPGN() {
        let immortalGame = String()
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
            + "22.Qf6+ Nxf6 23.Be7# 1-0\n"
        let pgn = try! PGN(parse: immortalGame)
        let game = Game(pgn: pgn)

        for move in game.playedMoves {
            print(move)
        }

        let returnGame = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn2 = try! PGN(parse: returnGame)
        let game2 = Game(pgn: pgn2)

        for move in game2.playedMoves {
            print(move)
        }        
        
    }

    func testPGNRepresentation() {

        let gameString = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
        let pgn = try! PGN(parse: gameString)
        let game = Game(pgn: pgn)

        XCTAssertNotNil(game.whitePlayer.name)
        XCTAssertNotNil(game.blackPlayer.name)
        XCTAssertEqual(game.whitePlayer.name, Optional("Fischer, Robert J."))
        XCTAssertEqual(game.blackPlayer.name, Optional("Spassky, Boris V."))

//        XCTAssertNotNil(game.currentPosition.outcome)
//        XCTAssertEqual(game.currentPosition.outcome, Optional(Outcome.draw))

//        let result = Game(pgn: game.pgn)
//        XCTAssertEqual(game.pgn, result.pgn)
//        XCTAssertEqual(game.board, result.board)
//        XCTAssertEqual(game.moveHistory, result.moveHistory)



    }

    // MARK: EPD Tests:

    // MARK: Sequence+Chess Tests:

    // MARK: Character+Chess Tests:

    // MARK: InternalTypes Tests:



}

class GameTests: XCTestCase {

}

// MARK: -

class GamePositionTests: XCTestCase {
//    func testInitialization() {
//        let _ = Game.Position()
//    }
//    func testInitializationDesignated() {
//        let position = Game.Position(
//            board: Board(),
//            playerTurn: .white,
//            castlingRights: CastlingRights(string: "KQkq")!,
//            enPassantTarget: nil,
//            halfmoves: 0,
//            fullmoves: 1)
//        XCTAssertEqual(position, Game.Position())
//    }
//    func testInitializationFen() {
//        for fen in sampleFens {
//            XCTAssertNotNil(Game.Position(fen: fen), "Could not create a position from: \(fen)")
//        }
//        let fen = Game.Position(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
//        XCTAssertEqual(fen!, Game.Position())
//    }
//    func testFen() {
//        for fen in sampleFens {
//            XCTAssertEqual(Game.Position(fen: fen)!.fen(), fen, "Could not correctly write fen: \(fen)")
//        }
//    }
//    func testEquatable() {
//        for fen in sampleFens {
//            XCTAssertEqual(Game.Position(fen: fen), Game.Position(fen: fen), "Could not correctly equate \(fen)")
//        }
//    }
}

// MARK: -

class OutcomeTests: XCTestCase {

    static let ww = "1-0"
    static let bw = "0-1"
    static let dr = "1/2-1/2"
    let outcomes = [Outcome(ww), Outcome(bw), Outcome(dr)]

    func testInitialization() {
        for outcome in outcomes {
            XCTAssertNotNil(outcome, "Could not create outcome: \(outcome)")
        }
    }

    func testWinningColor() {
        let results: [Color?] = [Color.white, Color.black, nil]
        for (outcome, color) in zip(outcomes, results) {
            XCTAssertEqual(outcome?.winningColor, color)
        }
    }

    func testValue() {
        let whiteResults = [1.0, 0.0, 0.5]
        let blackResults = [0.0, 1.0, 0.5]
        for (outcome, value) in zip(outcomes, whiteResults) {
            XCTAssertEqual(outcome?.value(for: .white), value)
        }
        for (outcome, value) in zip(outcomes, blackResults) {
            XCTAssertEqual(outcome?.value(for: .black), value)
        }
    }

    func testDescription() {
        let results = [OutcomeTests.ww, OutcomeTests.bw, OutcomeTests.dr]
        for (outcome, desc) in zip(outcomes, results) {
            XCTAssertEqual(outcome?.description, desc)
        }
    }

}

// MARK: -

class PlayerTests: XCTestCase {

}

class BitboardTests: XCTestCase {

}

class PieceTests: XCTestCase {

}

class ColorTests: XCTestCase {

}

class FileTests: XCTestCase {

}

class RankTests: XCTestCase {

}

class SquareTests: XCTestCase {

}

class MoveTests: XCTestCase {

}

class CastlingRightsTests: XCTestCase {

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
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"
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
            let _ = PGN(tagPairs: tagPair, moves: moves)
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
            let _ = PGN(tagPairs: dict, moves: moves)
        }
    }
}

class EPDTests: XCTestCase {

}

class BoardCoordinateTests: XCTestCase {

}
