//
//  PositionTests.swift
//  Engine
//
//  Created by Todd Olsen on 9/21/16.
//
//

import XCTest
@testable import Engine

class PositionTests: XCTestCase {

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

    func testInitialization() {
        for fen in sampleFens {
            let p = Position(fen: fen)
            XCTAssertNotNil(p)
        }
    }

    func testEquality() {
        XCTAssertEqual(Position(), Position())
    }

    func testFen() {
        for fen in sampleFens {
            let p = Position(fen: fen)!
            XCTAssertEqual(p.fen, fen)
        }
    }

    func testMoveForSanMove() {

        /*
           +-----------------+
         8 | . . b k . . . r |
         7 | N . . . N P P . |
         6 | . . . . . . . . |
         5 | . . . . . p P . |
         4 | . . . . p . . . |
         3 | P . . P . . . . |
         2 | . P P . . . . . |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */

        let fen = "2bk3r/N3NPP1/8/5pP1/4p3/P2P4/1PP5/R3K2R w KQkq f6 0 1"
        let position = Position(fen: fen)
        XCTAssertNotNil(position)

        let moves: [(String, Move, Piece?)] = [
            ("Ra2", Move(.a1, .a2), nil),   // regular
            ("gxf6", Move(.g5, .f6), nil),  // en passant
            ("Kd2", Move(.e1, .d2), nil),   // regular
            ("a4", Move(.a3, .a4), nil),    // pawn push
            ("b4", Move(.b2, .b4), nil),    // double pawn push
            ("dxe4", Move(.d3, .e4), nil),  // pawn capture
            ("O-O-O", Move(.e1, .c1), nil), // Castle queenside
            ("O-O", Move(.e1, .g1), nil),   // Castle kingside
            ("Nec6", Move(.e7, .c6), nil),  // disambiguated move
            ("Nexc8", Move(.e7, .c8), nil),  // disambiguated capture
            ("f8=Q", Move(.f7, .f8), Piece(queen: .white)), // pawn promotion
            ("gxh8=N", Move(.g7, .h8), Piece(knight: .white)) // pawn capture + promotion
        ]

        for (san, move, promotion) in moves {
            let result = position!.move(forSan: san)
            XCTAssertNotNil(result, "San: \(san) returned nil.")
            XCTAssertEqual(move, result!.0)
            XCTAssertEqual(promotion, result!.1)
        }

        let nils: [(String, Move)] = [
            ("Rg2", Move(.h1, .g2))
        ]

        for (san, _) in nils {
            let result = position!.move(forSan: san)
            XCTAssertNil(result, "san: \(san) should have returned nil. returned: \(result!)")
        }
    }

}

class MoveLegality: XCTestCase {

    func testPawnPushes() {
        /*
           +-----------------+
         8 | r n b q k b n r |
         7 | p p p p p p p p |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P P P P P P |
         1 | R N B Q K B N R |
           +-----------------+
             a b c d e f g h
         */
        let p = Position()
        XCTAssertEqual(p._legalTargetSquares(from: .d2), [.d3, .d4])
    }

    func testPawnCaptures() {
        /*
           +-----------------+
         8 | k . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . p . . . |
         5 | . . . P . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . K |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k7/8/4p3/3P4/8/8/8/7K w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .d5), [.d6, .e6])
    }

    func testEnPassant() {
        /*
           +-----------------+
         8 | k . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . p P . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . K |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k7/8/8/2pP4/8/8/8/7K w - c6 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .d5), [.c6, .d6])
    }

    func testKnightMoves() {
        /*
           +-----------------+
         8 | k . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . q . . . . |
         3 | . N . . . . . . |
         2 | . . . . . . . . |
         1 | . . K . . . . . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k7/8/8/8/3q5/1N6/8/2K5 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .b3), [.a1, .d2, .d4, .a5, .c5])
    }

    func testBishopMoves() {
        /*
           +-----------------+
         8 | k . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . r . . . . |
         5 | . . B . . . . . |
         4 | . . . . . . . . |
         3 | . . . . P . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . K |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k7/8/3r4/2B5/8/4P3/8/7K w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .c5), [.a3, .b4, .d4, .b6, .d6, .a7])
    }

//    func testRookMoves() {
//        /*
//
//         */
//        let p = Position(fen: "")!
//        XCTAssertEqual(p._legalTargetSquares(from: <#T##Square#>), [])
//    }

//    func testQueenMoves() {
//        /*
//
//         */
//        let p = Position(fen: "")!
//        XCTAssertEqual(p._legalTargetSquares(from: <#T##Square#>), [])
//    }

    func testKingMoves() {
        /*
           +-----------------+
         8 | k . . . . r . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . n . . . |
         2 | . . . . . . p . |
         1 | . . . . . . K . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k4r2/8/8/8/8/4n3/6p1/6K1 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .g1), [.h2])
        XCTAssertFalse(p.isKingInCheck)
    }

    func testKingInCheck() {
        /*
           +-----------------+
         8 | k . . . . r . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . n . . . |
         2 | R . . . . . . p |
         1 | . . . . . . K . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k4r2/8/8/8/8/4n3/R6p/6K1 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .g1), [.h1, .h2])
        XCTAssertEqual(p._legalTargetSquares(from: .a2), [.h2])
        XCTAssertTrue(p.isKingInCheck)
        XCTAssertFalse(p.isKingInMultipleCheck)
    }

    func testKingInMultipleCheck() {
        /*
           +-----------------+
         8 | k . . . . r . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . n . . |
         2 | R . . . . . . p |
         1 | . . . . . . K . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k4r2/8/8/8/8/5n2/R6p/6K1 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .g1), [.f1, .h1, .f2, .g2])
        XCTAssertEqual(p._legalTargetSquares(from: .a2), [])
        XCTAssertTrue(p.isKingInCheck)
        XCTAssertTrue(p.isKingInMultipleCheck)
    }

    func testDiscoveredSelfCheck() {
        /*
           +-----------------+
         8 | k . . . . . r . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . N . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . K . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k5r1/8/8/8/6N1/8/8/6K1 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .g4), [])
    }

    func testBlockingCheck() {
        /*
           +-----------------+
         8 | k . . . . . r . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . B . . K . |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "k5r1/8/8/8/8/8/8/3B2K1 w - - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .d1), [.g4])
    }

    func testRegularCastle() {
        /*
           +-----------------+
         8 | . . . . k . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P P P P P P |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQ - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .e1), [.c1, .d1, .f1, .g1])
    }

    func testCastlingAcrossObastacles() {
        /*
           +-----------------+
         8 | . . . . k . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P P P P P P |
         1 | R . . Q K . . R |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R2QK2R w KQ - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .e1), [.f1, .g1])
    }

    func testCastleRights() {
        /*
           +-----------------+
         8 | . . . . k . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P P P P P P |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */
        let p1 = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w K - 0 1")!
        XCTAssertEqual(p1._legalTargetSquares(from: .e1), [.d1, .f1, .g1])
        let p2 = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w Q - 0 1")!
        XCTAssertEqual(p2._legalTargetSquares(from: .e1), [.c1, .d1, .f1])
    }

    func testCastlingInCheck() {
        /*
           +-----------------+
         8 | . . . . k . . . |
         7 | . . . . q . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P P . P P P |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "4k3/4q3/8/8/8/8/PPPP1PPP/R3K2R w KQ - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .e1), [.d1, .f1])
    }

    func testCastlingAcrossAttackedSquares() {
        /*
           +-----------------+
         8 | . . . . k . . . |
         7 | . . . q . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | P P P . P P P P |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */
        let p = Position(fen: "4k3/3q4/8/8/8/8/PPP1PPPP/R3K2R w KQ - 0 1")!
        XCTAssertEqual(p._legalTargetSquares(from: .e1), [.f1, .g1])
    }
}

//        let test1: Test = {
//
//            /*
//               +-----------------+
//             8 | r n b q k b n r |
//             7 | p p p p p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R N B Q K B N R |
//               +-----------------+
//                 a b c d e f g h
//             */
//
//            let p1 = Position()
//
//            let sample1 = Test.Sample(
//                origin: .d2,
//                targets: [.d3, .d4]
//            )
//
//            let sample2 = Test.Sample(
//                origin: .b1,
//                targets: [.a3, .c3]
//            )
//
//            return Test(position: p1, samples: [sample1, sample2])
//        }()
//
//        let test2: Test = {
//
//            /*
//
//               +-----------------+
//             8 | k . . . . . . . |
//             7 | . . . . . . b b |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P . . . . . . |
//             1 | K . . . . . . . |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "k7/6bb/8/8/8/8/PP6/K7 w - - 0 1")
//            XCTAssertNotNil(position)
//
//            let sample1 = Test.Sample(
//                origin: .a2,
//                targets: [.a3, .a4]
//            )
//
//            let sample2 = Test.Sample(
//                origin: .b2,
//                targets: []
//            )
//
//            let sample3 = Test.Sample(
//                origin: .a1,
//                targets: []
//            )
//
//            return Test(position: position!, samples: [sample1, sample2, sample3])
//
//        }()
//
//        let test3: Test = {
//
//            /*
//
//               +-----------------+
//             8 | k . . . . . . . |
//             7 | . . . . . . b b |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . N . . |
//             2 | P . . . . . . . |
//             1 | K . . . . . . . |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "k7/6bb/8/8/8/5N3/P7/K7 w - - 0 1")
//            XCTAssertNotNil(position)
//
//            let sample1 = Test.Sample(
//                origin: .a1,
//                targets: []
//            )
//
//            let sample2 = Test.Sample(
//                origin: .a2,
//                targets: []
//            )
//
//            let sample3 = Test.Sample(
//                origin: .f3,
//                targets: [.d4, .e5]
//            )
//
//            return Test(position: position!, samples: [sample1, sample2, sample3])
//            
//        }()
//
//        let test4: Test = {
//
//            /*
//
//               +-----------------+
//             8 | . . . . k . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
//            XCTAssertNotNil(position)
//
//
//            let sample1 = Test.Sample(
//                origin: .e1,
//                targets: [.c1, .d1, .f1, .g1]
//            )
//
//            return Test(position: position!, samples: [sample1])
//
//        }()
//
//        let test5: Test = {
//
//            /*
//
//               +-----------------+
//             8 | . . . . k . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w Qkq - 0 1")
//            XCTAssertNotNil(position)
//
//            let sample1 = Test.Sample(
//                origin: .e1,
//                targets: [.c1, .d1, .f1]
//            )
//
//            return Test(position: position!, samples: [sample1])
//        }()
//
//
//
//
//        let test90: Test = {
//
//            /*
//
//               +-----------------+
//             8 | . . . k . . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . P p P p . |
//             3 | . . . . . . . . |
//             2 | P P P . P . P P |
//             1 | . . . K . . . . |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "3k4/8/8/8/3PpPp1/8/PPP1P1PP/3K4 b KQkq f3 0 1")
//            XCTAssertNotNil(position)
//
//            let sample1 = Test.Sample(
//                origin: .g4,
//                targets: [.f3, .g3]
//            )
//
//            let sample2 = Test.Sample(
//                origin: .e4,
//                targets: [.e3, .f3]
//            )
//
//            return Test(position: position!, samples: [sample1, sample2])
//            
//        }()
//
//        test1.perform()
//        test2.perform()
//        test3.perform()
//        test4.perform()
//        test5.perform()
//        test6.perform()
//
//    }
//
//    struct ExecutionTest {
//        typealias Example = (move: Move, promotion: Piece?, expectedFen: String)
//        let position: Position
//        let trueExamples: [Example]
//        let falseExamples: [Example]
//        func perform() {
//            for example in trueExamples {
//                let item = position._execute(uncheckedMove: example.move, promotion: example.promotion)
//                XCTAssertNotNil(item)
//                XCTAssertEqual(example.expectedFen, item!.position.fen)
//            }
//            for example in falseExamples {
//                let item = position._execute(uncheckedMove: example.move, promotion: example.promotion)
//                XCTAssertNil(item)
//            }
//        }
//    }
//
//    struct ItemConstructionTest {
//        let position: Position
//        let trueExecutions: [(move: Move, promotion: Piece?, expectedItem: HistoryItem)]
//        let falseExecutions: [(move: Move, promotion: Piece?)]
//        func perform() {
//            for execution in trueExecutions {
//                let result = position._execute(uncheckedMove: execution.move, promotion: execution.promotion)
//                XCTAssertNotNil(result)
//                XCTAssertEqual(result!, execution.expectedItem)
//            }
//            for execution in falseExecutions {
//                let result = position._execute(uncheckedMove: execution.move, promotion: execution.promotion)
//                XCTAssertNil(result)
//            }
//        }
//    }
//
//    func testExecutability() {
//
//        struct Test {
//            let position: Position
//            let trueMoves: [Move]
//            let falseMoves: [Move]
//            func perform() {
//                for move in trueMoves {
//                    XCTAssertTrue(position._canExecute(move: move))
//                }
//
//                for move in falseMoves {
//                    XCTAssertFalse(position._canExecute(move: move))
//                }
//            }
//        }
//
//        let test1: Test = {
//
//            /*
//               +-----------------+
//             8 | r n b q k b n r |
//             7 | p p p p p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R N B Q K B N R |
//               +-----------------+
//                 a b c d e f g h
//             */
//
//            let position = Position()
//
//            let trueMoves = [
//                Move(.d2, .d3),
//                Move(.d2, .d4),
//                Move(.g1, .f3)
//            ]
//
//            let falseMoves = [
//                Move(.d2, .d5),
//                Move(.d3, .d4)
//            ]
//
//            return Test(position: position, trueMoves: trueMoves, falseMoves: falseMoves)
//
//        }()
//
//        let test2: Test = {
//
//            /*
//             
//               +-----------------+
//             8 | k . . . . . . . |
//             7 | . . . . . . b b |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P . . . . . . |
//             1 | K . . . . . . . |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "k7/6bb/8/8/8/8/PP6/K7 w - - 0 1")
//            XCTAssertNotNil(position)
//
//            let trueMoves = [
//                Move(.a2, .a3),
//                Move(.a2, .a3)
//            ]
//            let falseMoves = [
//                Move(.b2, .b3),
//                Move(.b2, .b4),
//                Move(.a1, .b1)
//            ]
//
//            return Test(
//                position: position!,
//                trueMoves: trueMoves,
//                falseMoves: falseMoves
//                )
//        }()
//
//        let test3: Test = {
//
//            /*
//             
//               +-----------------+
//             8 | . . . . k . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
//            XCTAssertNotNil(position)
//
//            let trueMoves = [
//                Move(.e1, .g1),
//                Move(.e1, .c1)
//            ]
//
//            return Test(position: position!, trueMoves: trueMoves, falseMoves: [])
//
//        }()
//
//        let test4: Test = {
//
//            /*
//
//               +-----------------+
//             8 | . . . k . . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . P p P p . |
//             3 | . . . . . . . . |
//             2 | P P P . P . P P |
//             1 | . . . K . . . . |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//            let position = Position(fen: "3k4/8/8/8/3PpPp1/8/PPP1P1PP/3K4 b KQkq f3 0 1")
//            XCTAssertNotNil(position)
//
//            let trueMoves = [
//                Move(.e4, .f3),
//                Move(.g4, .f3)
//            ]
//
//            let falseMoves = [
//                Move(.e4, .d3),
//                Move(.e4, .e2)
//            ]
//
//            return Test(position: position!, trueMoves: trueMoves, falseMoves: falseMoves)
//
//        }()
//
//        test1.perform()
//        test2.perform()
//        test3.perform()
//        test4.perform()
//        
//    }
//
//    func testExecution() {
//
//        struct Test {
//
//            struct Sample {
//                let move: Move
//                let promotion: Piece?
//                let expectedFen: String?
//            }
//
//            let position: Position
//            let trueSamples: [Sample]
//            let falseSamples: [Sample]
//
//            func perform() {
//
//                for sample in trueSamples {
//                    let item = position._execute(uncheckedMove: sample.move, promotion: sample.promotion)
//                    XCTAssertNotNil(item)
//                    XCTAssertEqual(sample.expectedFen!, item!.position.fen)
//                }
//
//                for sample in falseSamples {
//                    let item = position._execute(uncheckedMove: sample.move, promotion: sample.promotion)
//                    XCTAssertNil(item)
//                }
//            }
//        }
//
//        let test1: Test = {
//
//            /*
//               +-----------------+
//             8 | r n b q k b n r |
//             7 | p p p p p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R N B Q K B N R |
//               +-----------------+
//                 a b c d e f g h
//             */
//
//            let position = Position()
//
//            // MARK: A double pawn push produce an en passant square.
//            let true1 = Test.Sample(
//                move: Move(.e2, .e4),
//                promotion: nil,
//                expectedFen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
//            )
//
//            return Test(
//                position: position,
//                trueSamples: [true1],
//                falseSamples: []
//            )
//
//        }()
//
//        test1.perform()
//
//        let test2: Test = {
//
//            /*
//
//               +-----------------+
//             8 | r . . . k . . r |
//             7 | p p p p p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//
//            let position = Position(fen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1")
//            XCTAssertNotNil(position)
//
//            // MARK: A white queenside castle should also move the queenside rook.
//            let sample1 = Test.Sample(
//                move: Move(.e1, .c1),
//                promotion: nil,
//                expectedFen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/2KR3R b kq - 1 1"
//            )
//
//            // MARK: A white kingside castle should also move the kingside rook.
//            let sample2 = Test.Sample(
//                move: Move(.e1, .g1),
//                promotion: nil,
//                expectedFen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R4RK1 b kq - 1 1"
//            )
//
//            return Test(position: position!, trueSamples: [sample1, sample2], falseSamples: [])
//
//        }()
//
//        let test3: Test = {
//
//            /*
//
//               +-----------------+
//             8 | r . . . k . . r |
//             7 | p p p . p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//
//            let position = Position(fen: "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R b KQkq - 0 1")
//            XCTAssertNotNil(position)
//
//            // MARK: A black queenside castle should also move the queenside rook.
//            let true1 = Test.Sample(
//                move: Move(.e8, .c8),
//                promotion: nil,
//                expectedFen: "2kr3r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQ - 1 2"
//            )
//
//            // MARK: A black kingside castle should also move the kingside rook.
//            let true2 = Test.Sample(
//                move: Move(.e8, .g8),
//                promotion: nil,
//                expectedFen: "r4rk1/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQ - 1 2"
//            )
//
//            return Test(position: position!, trueSamples: [true1, true2], falseSamples: [])
//            
//        }()
//
//        let test4: Test = {
//
//            /*
//
//             +-----------------+
//             8 | r . . . k . . r |
//             7 | p p p . p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | B . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//             +-----------------+
//             a b c d e f g h
//
//             */
//
//
//            let position = Position(fen: "r3k2r/pppppppp/8/8/B7/8/PPPPPPPP/R3K2R b KQkq - 0 1")
//            XCTAssertNotNil(position)
//
//            // MARK: King may not castle while in check
//            let false1 = Test.Sample(
//                move: Move(.e8, .c8),
//                promotion: nil,
//                expectedFen: nil
//            )
//
//            let false2 = Test.Sample(
//                move: Move(.e8, .g8),
//                promotion: nil,
//                expectedFen: nil
//            )
//
//            return Test(position: position!, trueSamples: [], falseSamples: [false1, false2])
//            
//        }()
//
//        let test5: Test = {
//
//            /*
//
//               +-----------------+
//             8 | r . . . k . . r |
//             7 | p p p . p p p p |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . Q . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//               +-----------------+
//                 a b c d e f g h
//
//             */
//
//
//            let position = Position(fen: "r3k2r/ppp1pppp/8/8/8/3Q4/PPPPPPPP/R3K2R b KQq - 0 1")
//            XCTAssertNotNil(position)
//
//            // MARK: King cannot castle across an attacked square.
//            let false1 = Test.Sample(
//                move: Move(.e8, .c8),
//                promotion: nil,
//                expectedFen: nil
//            )
//
//            // MARK: King may not castle without the having right to do so.
//            let false2 = Test.Sample(
//                move: Move(.e8, .g8),
//                promotion: nil,
//                expectedFen: nil
//            )
//
//            return Test(position: position!, trueSamples: [], falseSamples: [false1, false2])
//            
//        }()
//
////        test1.perform()
////        test2.perform()
////        test3.perform()
//        test4.perform()
////        test5.perform()
//
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//    
//}
