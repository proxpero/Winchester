//
//  BoardTests.swift
//  Endgame
//
//  Created by Todd Olsen on 9/21/16.
//
//

import XCTest
@testable import Endgame

class BoardTests: XCTestCase {

    let sampleFens = [
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
        "1k1r4/pp1b1R2/3q2pp/4p3/2B5/4Q3/PPP2B2/2K5",
        "r1b1k3/p2p1Nr1/n2b3p/3pp1pP/2BB1p2/P3P2R/Q1P3P1/R3K1N1",
        "r1b1k2r/pp1n1ppp/2p1p3/q5B1/1b1P4/P1n1PN2/1P1Q1PPP/2R1KB1R",
        "5rk1/p5pp/2p3p1/1p1pR3/3P2P1/2N5/PP3n2/2KB4",
        "rnbq1rk1/ppp3pp/3bpn2/3p1p2/2PP4/2NBPN2/PP3PPP/R1BQK2R",
        "8/5R2/8/r2KB3/6k1/8/8/8",
        "rnbqkbnr/pppppp2/7p/6pP/8/8/PPPPPPP1/RNBQKBNR",
        "rnbqkbnr/pp1ppppp/8/8/2pP4/2P2N2/PP2PPPP/RNBQKB1R",
        "rnbqkbnr/pp1ppppp/2p5/8/6P1/2P5/PP1PPP1P/RNBQKBNR",
        "rnb1kbnr/ppq1pppp/2pp4/8/6P1/2P5/PP1PPPBP/RNBQK1NR",
        "rn2kbnr/p1q1ppp1/1ppp3p/8/4B1b1/2P4P/PPQPPP2/RNB1K1NR",
        "rnkq1bnr/p3ppp1/1ppp3p/3B4/6b1/2PQ3P/PP1PPP2/RNB1K1NR",
        "rn1q1bnr/3kppp1/2pp3p/pp6/1P2b3/2PQ1N1P/P2PPPB1/RNB1K2R",
        "rnkq1bnr/4pp2/2pQ2pp/pp6/1P5N/2P4P/P2PPP2/RNB1KB1b",
        "rn3b1r/1kq1p3/2pQ1npp/Pp6/4b3/2PPP2P/P4P2/RNB1KB2",
        "r4br1/8/k1p2npp/Ppn1p3/P7/2PPP1qP/4bPQ1/RNB1KB2",
        "rnbqk1nr/p2p3p/1p5b/2pPppp1/8/P7/1PPQPPPP/RNB1KBNR",
        "rnb1k2r/pp1p1p1p/1q1P4/2pnpPp1/6P1/2N5/PP1BP2P/R2QKBNR",
        "1n4kr/2B4p/2nb2b1/ppp5/P1PpP3/3P4/5K2/1N1R4",
        "r2n3r/1bNk2pp/6P1/pP3p2/3pPqnP/1P1P1p1R/2P3B1/Q1B1bKN1"
    ]


    func testInitialization() {

        let boardFromCharacters = Board(pieces: [
            ["r", "n", "b", "q", "k", "b", "n", "r"],
            ["p", "p", "p", "p", "p", "p", "p", "p"],
            [" ", " ", " ", " ", " ", " ", " ", " "],
            [" ", " ", " ", " ", " ", " ", " ", " "],
            [" ", " ", " ", " ", " ", " ", " ", " "],
            [" ", " ", " ", " ", " ", " ", " ", " "],
            ["P", "P", "P", "P", "P", "P", "P", "P"],
            ["R", "N", "B", "Q", "K", "B", "N", "R"]
            ])
        XCTAssertNotNil(boardFromCharacters)
        XCTAssert(Board() == boardFromCharacters!)

        for fen in sampleFens {
            XCTAssertNotNil(Board(fen: fen))
        }

    }

    func testEquality() {
        XCTAssertEqual(Board(), Board())
        var b1 = Board()
        b1.removePiece(at: .a4)
        var b2 = Board()
        b2.removePiece(at: .e4)
        XCTAssertEqual(Board(), b2)
    }

    func testFen() {
        for fen in sampleFens {
            let b = Board(fen: fen)!
            XCTAssertEqual(b.fen, fen)
        }
    }

    func testBoardPieces() {

        let board = Board()

        XCTAssert(board.pieces.count == 32)
        XCTAssert(Set(board.pieces) == Set(Piece.all))

        let white = board.whitePieces
        XCTAssert(white.count == 16)
        XCTAssert(Set(white) == Set(Piece.whitePieces))

        let black = board.blackPieces
        XCTAssert(black.count == 16)
        XCTAssert(Set(black) == Set(Piece.blackPieces))

        XCTAssert(board.occupiedSpaces.count == 32)
        XCTAssert(board.occupiedSpaces == board.bitboard(for: .white) | board.bitboard(for: .black))
        
    }

    func testBoardIterator() {

        let board = Board()
        let spaces = Array(board)
        let pieces = spaces.flatMap { $0.piece }
        let whites = pieces.filter { $0.color.isWhite }
        let blacks = pieces.filter { $0.color.isBlack }
        let unoccupied = spaces.filter { $0.piece == nil }
        XCTAssertEqual(spaces.count, 64)
        XCTAssertEqual(pieces.count, 32)
        XCTAssertEqual(whites.count, 16)
        XCTAssertEqual(blacks.count, 16)
        XCTAssertEqual(unoccupied.count, 32)
        for (index, space) in spaces.enumerated() {
            XCTAssert(space.square == Square(rawValue: index))
        }

    }

    func testBoardSubscript() {
        var board = Board()
        XCTAssertEqual(Piece(pawn: .white), board[.e2])
        XCTAssertEqual(Piece(knight: .black), board[.g8])
        let blackpawn = Piece(pawn: .black)
        let location = ("A", 3) as Location
        XCTAssertNil(board[location])
        board[location] = blackpawn
        XCTAssertNotNil(board[location])
        XCTAssertEqual(blackpawn, board[location])
        board[location] = nil
        XCTAssertNil(board[location])
    }

//    func testBoardSwap() {
//        let start = Board()
//        var board = start
//        let loc1 = ("D", 1) as Location
//        let loc2 = ("F", 2) as Location
//        board.swap(loc1, loc2)
//        XCTAssertEqual(start[loc1], board[loc2])
//        XCTAssertEqual(start[loc2], board[loc1])
//    }

    func testSpace() {
        let file = File.e
        let rank = Rank.four
        let location = Location(file: file, rank: rank)
        let square = Square(file: file, rank: rank)
        let space = Board.Space(square: square)
        XCTAssert(space == Board.Space(file: file, rank: rank))
        XCTAssert(space == Board.Space(location: location))

        XCTAssert(space.location == location)
        XCTAssert(space.square == square)

        let piece = Piece(knight: .white)
        var knightSpace = Board.Space(piece: piece, square: square)
        XCTAssertNotNil(knightSpace.piece)
        XCTAssert(knightSpace.piece! == piece)

        let knight = knightSpace.clear()
        XCTAssertNil(knightSpace.piece)
        XCTAssert(piece == knight)
    }
}

class BoardAttacks: XCTestCase {

    func testAttacksForPiece() {
        /*
           +-----------------+
         8 | . . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . Q . P . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . . |
           +-----------------+
             a b c d e f g h

           +-----------------+
         8 | 1 . . 1 . . 1 . |
         7 | . 1 . 1 . 1 . . |
         6 | . . 1 1 1 . . . |
         5 | 1 1 1 . 1 1 . . |
         4 | . . 1 1 1 . . . |
         3 | . 1 . 1 . 1 . . |
         2 | 1 . . 1 . . 1 . |
         1 | . . . 1 . . . 1 |
           +-----------------+
             a b c d e f g h
         */
        let board = Board(fen: "8/8/8/3Q1P2/8/8/8/8")!
        XCTAssertEqual(board.attacks(for: Piece.init(queen: .white), obstacles: Square.f5.bitboard), Bitboard(rawValue: 0x492a1c371c2a4988))
    }

    func testAttacksForColor() {
        /*
           +-----------------+
         8 | . . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . Q . P . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . . |
           +-----------------+
             a b c d e f g h

           +-----------------+
         8 | 1 . . 1 . . 1 . |
         7 | . 1 . 1 . 1 . . |
         6 | . . 1 1 1 . 1 . |
         5 | 1 1 1 . 1 1 . . |
         4 | . . 1 1 1 . . . |
         3 | . 1 . 1 . 1 . . |
         2 | 1 . . 1 . . 1 . |
         1 | . . . 1 . . . 1 |
           +-----------------+
             a b c d e f g h
         */
        let board = Board(fen: "8/8/8/3Q1P2/8/8/8/8")!
        XCTAssertEqual(board.attacks(for: .white), Bitboard(rawValue: 0x492a5c371c2a4988))
    }

    func testDefendedOccupations() {
        /*
           +-----------------+
         8 | . . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . Q . P . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . . |
           +-----------------+
             a b c d e f g h

           +-----------------+
         8 | 1 . . 1 . . 1 . |
         7 | . 1 . 1 . 1 . . |
         6 | . . 1 1 1 . 1 . |
         5 | 1 1 1 . 1 1 . . |
         4 | . . 1 1 1 . . . |
         3 | . 1 . 1 . 1 . . |
         2 | 1 . . 1 . . 1 . |
         1 | . . . 1 . . . 1 |
           +-----------------+
             a b c d e f g h
         */
//        let board = Board(fen: "8/8/8/3Q1P2/8/8/8/8")!
//        XCTAssertEqual(board._defendedOccupations(for: .white), Square.f5.bitmask)
    }

    func testAttackers_To_Square_Color() {

        typealias TestCase = (
            fen: String,
            square: Square,
            color: Color,
            result: Bitboard
        )

        /*
         Case 1
           +-----------------+
         8 | Q . . . . . . Q |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | Q . . . . . . . |
           +-----------------+
             a b c d e f g h
         */

        let case1: TestCase = (
            "Q6Q/8/8/8/8/8/8/Q7",
            .h1,
            .white,
            Square.a1.bitboard | Square.a8.bitboard | Square.h8.bitboard
        )

        /*
         Case 2
         +-----------------+
         8 | Q . . . . . . Q |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | . . . . . . . . |
         3 | . . . . . . . . |
         2 | . . . . . . . . |
         1 | Q . . . . . r . |
         +-----------------+
         a b c d e f g h
         */

        let case2: TestCase = (
            "Q6Q/8/8/8/8/8/8/Q5r1",
            .h1,
            .white,
            Square.a8.bitboard | Square.h8.bitboard
        )

        let testCases = [case1, case2]

        for testCase in testCases {
            let board = Board(fen: testCase.fen)!
            XCTAssertEqual(board.attackers(targeting: testCase.square, color: testCase.color), testCase.result)
        }

    }

    func testAttacksByPieceToSquare() {

        typealias TestCase = (
            fen: String,
            square: Square,
            color: Color,
            result: Bitboard
        )

        /*
         Case 1
         +-----------------+
         8 | . . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . p . . . . |
         4 | . . . . . N . . |
         3 | . . N . . . . . |
         2 | . . . . . . . . |
         1 | . . . . . . . . |
         +-----------------+
         a b c d e f g h
         */

        let expected = (Square.c3.bitboard | Square.f4.bitboard)
        let result = Board(fen: "8/8/8/3p4/5N2/2N5/8/8")!.attacks(by: Piece(knight: .white), to: .d5)

        XCTAssertEqual(expected, result)

    }

    func testAttackersToKingForColor() {

        typealias TestCase = (fen: String, color: Color, squares: Array<Square>)

        /*
         Case 1
           +-----------------+
         8 | B . . . R . . . |
         7 | . . . . . . . . |
         6 | . . . . . . . . |
         5 | . . . . . . . . |
         4 | Q . . . k . . . |
         3 | . . . P . . N . |
         2 | . . . . . . . . |
         1 | . . . . . . . . |
           +-----------------+
             a b c d e f g h
         */

        let case1: TestCase = (
            "B3R3/8/8/8/Q3k3/3P2N1/8/8",
            .black,
            [.a8, .e8, .a4, .d3, .e8, .g3]
        )

        /*
         Case 2
           +-----------------+
         8 | . . . . . . . . |
         7 | . . . . . . . . |
         6 | . . . q . q . . |
         5 | . . p . R . . . |
         4 | . . . K . . q r |
         3 | . . p . P . . . |
         2 | . . . . . . . . |
         1 | b . . . . . . . |
           +-----------------+
             a b c d e f g h
         */

        let case2: TestCase = (
            "8/8/3q1q2/2p1R3/3K2qr/2p1P3/8/b7",
            .white,
            [.c5, .d6, .g4]
        )

        /*
         Case 3
         +-----------------+
         8 | . Q . . . . . . |
         7 | . . . Q . . . . |
         6 | . . . . Q . . . |
         5 | Q Q . k Q . . . |
         4 | . . . . . . . . |
         3 | . Q . . . . . . |
         2 | Q . . Q . . . . |
         1 | . . . . . . . Q |
         +-----------------+
         a b c d e f g h
         */

        let case3: TestCase = (
            "1Q6/3Q4/4Q3/QQ1kQ3/8/1Q6/12Q4/7Q",
            .black,
            [.b3, .b5, .d7, .e6, .e5, .d2, .h1]
        )

        let testCases = [case1, case2, case3]

        for testCase in testCases {
            let board = Board(fen: testCase.fen)!
            let result = testCase.squares.reduce(Bitboard()) { $0 | $1.bitboard }
            XCTAssertEqual(board.attackersToKing(for: testCase.color), result)
        }

    }

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

    }
}
