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
         7 | N . . . N . . . |
         6 | . . . . . . . . |
         5 | . . . . . p P . |
         4 | . . . . p . . . |
         3 | P . . P . . . . |
         2 | . P P . . . . . |
         1 | R . . . K . . R |
           +-----------------+
             a b c d e f g h
         */

        let fen = "2bk3r/N3N3/8/5pP1/4p3/P2P4/1PP5/R3K2R w KQkq f6 0 1"
        let position = Position(fen: fen)
        XCTAssertNotNil(position)

//        let moves: [(String, Move)] = [
//            ("Ra2", Move(.a1, .a2)),   // regular
//            ("gxf6", Move(.g5, .f6)),  // en passant
//            ("Kd2", Move(.e1, .d2)),   // regular
//            ("dxe4", Move(.d3, .e4)),  // pawn capture
//            ("O-O-O", Move(.e1, .c1)), // Castle queenside
//            ("O-O", Move(.e1, .g1)),   // Castle kingside
//            ("Nec6", Move(.e7, .c6)),  // disambiguated move
//            ("Nexc8", Move(.e7, .c8))  // disambiguated capture
//        ]
//
//        for (san, move) in moves {
//            let result = position!.move(forSan: san)
//            XCTAssertNotNil(result, "San: \(san) returned nil.")
//            XCTAssertEqual(move, result!)
//        }

        let nils: [(String, Move)] = [
            ("Rg2", Move(.h1, .g2))
        ]

        for (san, _) in nils {
            let result = position!.move(forSan: san)
            XCTAssertNil(result, "san: \(san) should have returned nil. returned: \(result!)")
        }
    }

    struct ExecutableTest {
        let position: Position
        let trueMoves: [Move]
        let falseMoves: [Move]
        func perform() {
            for move in trueMoves {
                XCTAssertTrue(position._canExecute(move: move))
            }

            for move in falseMoves {
                XCTAssertFalse(position._canExecute(move: move))
            }
        }
    }

    struct LegalityTest {
        struct Example {
            let origin: Square
            let trueTargets: [Square]
            let falseTargets: [Square]
        }
        let position: Position
        let examples: [Example]
        func performTest() {
            for example in examples {
                for target in example.trueTargets {
                    XCTAssertTrue(position._legalTargetSquares(from: example.origin).contains(target), "\(target.description) is a legal target from \(example.origin.description)")
                }
                for target in example.falseTargets {
                    XCTAssertFalse(position._legalTargetSquares(from: example.origin).contains(target), "\(target.description) is NOT a legal target from \(example.origin.description)")
                }
            }
        }
    }

    struct ExecutionTest {
        typealias Example = (move: Move, promotion: Piece?, expectedFen: String)
        let position: Position
        let trueExamples: [Example]
        let falseExamples: [Example]
        func performTest() {
            for example in trueExamples {
                let item = position._execute(uncheckedMove: example.move, promotion: example.promotion)
                XCTAssertNotNil(item)
                XCTAssertEqual(example.expectedFen, item!.position.fen)
            }
            for example in falseExamples {
                let item = position._execute(uncheckedMove: example.move, promotion: example.promotion)
                XCTAssertNil(item)
            }
        }
    }

    struct PositionTest {
        let position: Position
        let executables: [ExecutableTest]
        let legalities: [LegalityTest]
        let executions: [ExecutionTest]
    }

    func testSamplePositions() {

//        let sample1: PositionTest = {
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
//            let executable1: ExecutableTest = {
//
//                let trueMoves = [
//                    Move(.d2, .d3),
//                    Move(.d2, .d4),
//                    Move(.g1, .f3)
//                ]
//
//                let falseMoves = [
//                    Move(.d2, .d5),
//                    Move(.d3, .d4)
//                ]
//
//                return ExecutableTest(
//                    position: position,
//                    trueMoves: trueMoves,
//                    falseMoves: falseMoves
//                )
//
//            }()
//
//
//
//        }()


    }

    func testCanExecute() {

        struct Sample {
            let position: Position
            let trueMoves: [Move]
            let falseMoves: [Move]
            func performTest() {
                for move in trueMoves {
                    XCTAssertTrue(position._canExecute(move: move))
                }

                for move in falseMoves {
                    XCTAssertFalse(position._canExecute(move: move))
                }
            }
        }

        let sample1: Sample = {

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

            let p1 = Position()

            let trueMoves = [
                Move(.d2, .d3),
                Move(.d2, .d4),
                Move(.g1, .f3)
            ]

            let falseMoves = [
                Move(.d2, .d5),
                Move(.d3, .d4)
            ]

            return Sample(position: p1, trueMoves: trueMoves, falseMoves: falseMoves)

        }()

        let sample2: Sample = {

            /*
             
               +-----------------+
             8 | k . . . . . . . |
             7 | . . . . . . b b |
             6 | . . . . . . . . |
             5 | . . . . . . . . |
             4 | . . . . . . . . |
             3 | . . . . . . . . |
             2 | P P . . . . . . |
             1 | K . . . . . . . |
               +-----------------+
                 a b c d e f g h

             */

            let fen = "k7/6bb/8/8/8/8/PP6/K7 w - - 0 1"
            let p2 = Position(fen: fen)
            XCTAssertNotNil(p2)

            let trueMoves = [
                Move(.a2, .a3),
                Move(.a2, .a3)
            ]
            let falseMoves = [
                Move(.b2, .b3),
                Move(.b2, .b4),
                Move(.a1, .b1)
            ]

            return Sample(
                position: p2!,
                trueMoves: trueMoves,
                falseMoves: falseMoves
                )
        }()

        let sample3: Sample = {

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

            let fen = "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
            let p3 = Position(fen: fen)
            XCTAssertNotNil(p3)

            let trueMoves = [
                Move(.e1, .g1),
                Move(.e1, .c1)
            ]

            return Sample(position: p3!, trueMoves: trueMoves, falseMoves: [])

        }()

        let sample4: Sample = {

            /*

               +-----------------+
             8 | . . . k . . . . |
             7 | . . . . . . . . |
             6 | . . . . . . . . |
             5 | . . . . . . . . |
             4 | . . . P p P p . |
             3 | . . . . . . . . |
             2 | P P P . P . P P |
             1 | . . . K . . . . |
               +-----------------+
                 a b c d e f g h

             */

            let fen = "3k4/8/8/8/3PpPp1/8/PPP1P1PP/3K4 b KQkq f3 0 1"
            let p4 = Position(fen: fen)
            XCTAssertNotNil(p4)

            let trueMoves = [
                Move(.e4, .f3),
                Move(.g4, .f3)
            ]

            let falseMoves = [
                Move(.e4, .d3),
                Move(.e4, .e2)
            ]

            return Sample(position: p4!, trueMoves: trueMoves, falseMoves: falseMoves)

        }()

        sample1.performTest()
        sample2.performTest()
        sample3.performTest()
        sample4.performTest()
        
    }

    func testLegalTargetSquares() {

//        struct Sample {
//            let Square
//            let trueTargets: [Square]
//            let falseTargets: [Square]
//        }
//
//        struct TestPositon {
//            let position: Position
//            let samples: [Sample]
//            func performTest() {
//                for sample in samples {
//                    for target in sample.trueTargets {
//                        XCTAssertTrue(position._legalTargetSquares(from: sample.origin).contains(target), "\(target.description) is a legal target from \(sample.origin.description)")
//                    }
//                    for target in sample.falseTargets {
//                        XCTAssertFalse(position._legalTargetSquares(from: sample.origin).contains(target), "\(target.description) is NOT a legal target from \(sample.origin.description)")
//                    }
//                }
//            }
//        }
//
//        let position1: TestPositon = {
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
//            let sample1 = Sample(
//                origin: .d2,
//                trueTargets: [.d3, .d4],
//                falseTargets: [.d5, .e3]
//            )
//
//            let sample2 = Sample(
//                origin: .b1,
//                trueTargets: [.a3, .c3],
//                falseTargets: [.d2]
//            )
//
//            return TestPositon(position: p1, samples: [sample1, sample2])
//        }()
//
//        let position2: TestPositon = {
//
//            /*
//
//             +-----------------+
//             8 | k . . . . . . . |
//             7 | . . . . . . b b |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P . . . . . . |
//             1 | K . . . . . . . |
//             +-----------------+
//             a b c d e f g h
//
//             */
//
//            let fen = "k7/6bb/8/8/8/8/PP6/K7 w - - 0 1"
//            let p2 = Position(fen: fen)
//            XCTAssertNotNil(p2)
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
//            return Sample(
//                position: p2!,
//                trueMoves: trueMoves,
//                falseMoves: falseMoves
//            )
//        }()
//
//        let sample3: Sample = {
//
//            /*
//
//             +-----------------+
//             8 | . . . . k . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . . . . . . |
//             3 | . . . . . . . . |
//             2 | P P P P P P P P |
//             1 | R . . . K . . R |
//             +-----------------+
//             a b c d e f g h
//
//             */
//
//            let fen = "4k3/8/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
//            let p3 = Position(fen: fen)
//            XCTAssertNotNil(p3)
//
//            let trueMoves = [
//                Move(.e1, .g1),
//                Move(.e1, .c1)
//            ]
//
//            return Sample(position: p3!, trueMoves: trueMoves, falseMoves: [])
//
//        }()
//
//        let sample4: Sample = {
//
//            /*
//
//             +-----------------+
//             8 | . . . k . . . . |
//             7 | . . . . . . . . |
//             6 | . . . . . . . . |
//             5 | . . . . . . . . |
//             4 | . . . P p P p . |
//             3 | . . . . . . . . |
//             2 | P P P . P . P P |
//             1 | . . . K . . . . |
//             +-----------------+
//             a b c d e f g h
//
//             */
//
//            let fen = "3k4/8/8/8/3PpPp1/8/PPP1P1PP/3K4 b KQkq f3 0 1"
//            let p4 = Position(fen: fen)
//            XCTAssertNotNil(p4)
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
//            return Sample(position: p4!, trueMoves: trueMoves, falseMoves: falseMoves)
//            
//        }()
//
//
//        position1.performTest()

    }

    func testExecuteMove() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
