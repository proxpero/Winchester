//
//  Game+UndoTests.swift
//  Endgame
//
//  Created by Todd Olsen on 3/27/17.
//
//

import XCTest
@testable import Endgame

class GameUndoTests: XCTestCase {

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

    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        let moves = try! "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testUndoOneMove() {
        let game = Game()
        try! game.execute(sanMoves: "e4")
        let initialBoard = game.currentPosition.board
        let delegate = TestDelegate()
        game.delegate = delegate
        game.undo(count: 1)
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate.events.count, 1)
        XCTAssertEqual(game.currentPosition.board, initialBoard.execute(transactions: delegate.transactions))

    }

    func testRedoOneMove() {
        let game = Game()
        let move = Move(origin: .e2, target: .e4)
        game.execute(move: move)
        let finalPosition = game.currentPosition
        game.moveIndex = 0
        game.delegate = delegate
        game.redo(count: 1)
        XCTAssertEqual(game.moveIndex, 1)
        XCTAssertEqual(delegate!.events.count, 1)
        XCTAssertEqual(game.currentPosition, finalPosition)
    }

    func testUndoMultipleMoves() {

        game.delegate = delegate
        game.undo(count: 5)
        XCTAssertEqual(game.moveIndex, 7)
        XCTAssertEqual(delegate!.events.count, 5)

    }

    func testRedoMultipleMoves() {

        game.moveIndex = 2
        game.delegate = delegate
        game.redo(count: 5)
        XCTAssertEqual(game.moveIndex, 7)
        XCTAssertEqual(delegate!.events.count, 5)

    }

    func testUndoAll() {

        game.delegate = delegate
        game.undoAll()
        let finalPosition = game.currentPosition
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate!.events.count, 12)
        XCTAssertEqual(game.currentPosition, finalPosition)
    }

    func testRedoAll() {

        let initialPosition = game.currentPosition
        game.moveIndex = 0
        game.delegate = delegate
        game.redoAll()
        let lastPosition = game.currentPosition
        XCTAssertEqual(game.moveIndex, 12)
        XCTAssertEqual(delegate!.events.count, 12)
        XCTAssertEqual(initialPosition, lastPosition)

    }

    func testUndoTooLarge() {

        game.delegate = delegate
        game.undo(count: 500)
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate!.events.count, 12)

    }

    func testRedoTooLarge() {

        game.moveIndex = 0
        game.delegate = delegate
        game.redo(count: 500)
        XCTAssertEqual(game.moveIndex, 12)
        XCTAssertEqual(delegate!.events.count, 12)

    }

    func testUndoTooSmall() {

        game.delegate = delegate
        game.undo(count: -5)
        XCTAssertEqual(game.moveIndex, 12)
        // No op.
        XCTAssertNil(delegate!.events)

    }

    func testRedoTooSmall() {

        game.moveIndex = 0
        game.delegate = delegate
        game.redo(count: -5)
        XCTAssertEqual(game.moveIndex, 0)
        // No op.
        XCTAssertNil(delegate!.events)
        
    }

    func testUndoRedo() {
        let initialPosition = game.currentPosition
        game.undoAll()
        game.redoAll()
        let finalPosition = game.currentPosition
        XCTAssertEqual(initialPosition, finalPosition)
    }

    func testRedoUndo() {
        game.moveIndex = 0
        let initialPosition = game.currentPosition
        game.redoAll()
        game.undoAll()
        let finalPosition = game.currentPosition
        XCTAssertEqual(initialPosition, finalPosition)
    }

    func testUndoOneTransaction() {
        let game = Game()
        try! game.execute(sanMoves: "e4")
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.undo(count: 1)
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate!.events.count, 1)
        XCTAssertEqual(delegate?.transactions.count, 1)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testRedoOneTransaction() {
        let game = Game()
        try! game.execute(sanMoves: "e4")
        game.moveIndex = 0
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.redo(count: 1)
        XCTAssertEqual(game.moveIndex, 1)
        XCTAssertEqual(delegate!.events.count, 1)
        XCTAssertEqual(delegate?.transactions.count, 1)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeUndoTransactions() {
        let game = Game()
        try! game.execute(sanMoves: "e4 d5 e5")
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.undo(count: 3)
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate!.events.count, 3)
        XCTAssertEqual(delegate!.transactions.count, 2)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeRedoTransactions() {
        let game = Game()
        try! game.execute(sanMoves: "e4 d5 e5")
        game.moveIndex = 0
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.redo(count: 3)
        XCTAssertEqual(game.moveIndex, 3)
        XCTAssertEqual(delegate!.events.count, 3)
        XCTAssertEqual(delegate!.transactions.count, 2)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeCaptureUndoTransactions() {
        game.moveIndex = 4
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.undoAll()
        XCTAssertEqual(game.moveIndex, 0)
        XCTAssertEqual(delegate!.events.count, 4)
        XCTAssertEqual(delegate!.transactions.count, 3)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeCaptureRedoTransactions() {
        game.moveIndex = 0
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.redo(count: 4)
        XCTAssertEqual(game.moveIndex, 4)
        XCTAssertEqual(delegate!.events.count, 4)
        XCTAssertEqual(delegate!.transactions.count, 3)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeCastleUndoTransactions() {
        let game = Game()
        try! game.execute(sanMoves: "1. g3 d5 2. Bg2 e5 3. d4 exd4 4. Qxd4 Nf6 5. Bg5 Be7 6. Nc3 c6 7. O-O-O O-O 8. Nf3 Nbd7".moves())
        game.moveIndex = 15
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.undo(count: 4)
        XCTAssertEqual(delegate!.transactions.count, 6) // 4+2 for rook moves
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergeCastleRedoTransactions() {
        let game = Game()
        try! game.execute(sanMoves: "1. g3 d5 2. Bg2 e5 3. d4 exd4 4. Qxd4 Nf6 5. Bg5 Be7 6. Nc3 c6 7. O-O-O O-O 8. Nf3 Nbd7".moves())
        game.moveIndex = 11
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.redo(count: 4)
        XCTAssertEqual(delegate!.transactions.count, 6) // 4+2 for rook moves
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

}

class GameTransactionTests: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1. g3 d5 2. Bg2 e5 3. d4 exd4 4. Qxd4 Nf6 5. Bg5 Be7 6. Nc3 c6 7. O-O-O O-O 8. Nf3 Nbd7 9. h4 Qb6 10. Qd2 Re8 11. Nd4 Ne5 12. Nb3 Nc4 13. Qd4 h6 14. Bf4 Ng4 15. Rhf1 Bf6 16. Qxb6 axb6 17. Nd2 b5 18. Nxc4 bxc4 19. e4 Bxc3 20. bxc3 dxe4 21. Kb2 Bf5 22. Bh3 h5 23. Bxg4 Bxg4 24. Rd4 c5 25. Rd6 Red8 26. Re1 Bf3 27. Rb6 Rd7 28. Be3 Rc8 29. Rb5 f6 30. Rxc5 Rxc5 31. Bxc5 Kf7 32. Bd4 Rd5 33. a4 Ke6 34. Ka3 Kf5 35. Kb4 Kg4 36. Kxc4 Rd7 37. a5 Kh3 38. Kb5 Kg2 39. Kb6 g5 40. Be3 gxh4 41. gxh4 f5 42. c4 f4 43. Bxf4 Kxf2 44. Re3 Rf7 45. Bg5 Rg7 46. c5 Rxg5 47. hxg5 Kxe3 48. g6 h4 49. c6 bxc6 50. g7 h3 51. a6 h2 52. a7 h1=Q 53. g8=Q Kf2 54. a8=Q e3 55. Qa4 e2 56. Qd4+ Kf1 57. Qd3 Kf2 58. Qd2 Qb1+ 59. Kc7 c5 60. Qb3 Qxb3 61. cxb3 Kf1 62. Qd3 Kf2 63. Qc2 Kf1 64. Qc4 Kf2 65. Qxc5+ Kf1 66. Qc4 Kf2 67. Qd4+ Kf1 68. Qd3 Kf2 69. Qd2 Kf1 70. Qd3 Kf2 71. Qd4+ Kf1 72. Qc4 Kf2 73. Qc5+ Kf1 74. Qc4 Kf2 75. Qd4+ Kf1 76. Qd3 Kf2 77. Qd2 Kf1 78. Qd3 Bg2".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testMergePromotionUndoTransactions() {
        game.moveIndex = 108
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.undo(count: 6)
        XCTAssertEqual(delegate!.transactions.count, 5)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testMergePromotionRedoTransactions() {
        game.moveIndex = 102
        let initialBoard = game.currentPosition.board
        game.delegate = delegate
        game.redo(count: 6)
        XCTAssertEqual(delegate!.transactions.count, 5)
        XCTAssertEqual(initialBoard.execute(transactions: delegate!.transactions), game.currentPosition.board)
    }

    func testSingleUndoTransactions() {
        let index = 9
        game.moveIndex = index
        let initialBoard = game.currentPosition.board
        let delegate = TestDelegate()
        game.delegate = delegate
        game.undoAll()
        let actual = initialBoard.execute(transactions: delegate.transactions)
        let expected = game.currentPosition.board
        XCTAssertEqual(actual, expected, "for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
    }

    func testUndoNTransactions() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }
    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
    }

    func testRedoNTransactions() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }

    }



}

class GameTransactionTests1: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4 Bxb4 5. c3 Ba5 6. d4 exd4 7. O-O dxc3 8. Qb3 Qe7 9. Nxc3 Nf6 10. Nd5 Nxd5 11. exd5 Ne5 12. Nxe5 Qxe5 13. Bb2 Qg5 14. h4 Qxh4 15. Bxg7 Rg8 16. Rfe1+ Kd8 17. Qg3".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testUndoNTransactions() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }
    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
    }

    func testRedoNTransactions() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
        
    }

}

class GameTransactionTests2: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.f4 Qc7 7.a4 g6 8.Bd3 Bg7 9.Nf3 Bg4 10.Be3 Nc6 11.O-O O-O 12.Qe1 Bxf3 13.Rxf3 e6 14.Qh4 Qd8 15.Rh3 h5 16.Be2 d5 17.e5 Nd7 18.Qf2 Qe7 19.g4 hxg4 20.Bxg4 Rad8 21.Rd1 f5 22.Bf3 Rf7 23.Kh1 g5 24.Bh5 g4 25.Bxf7+ Qxf7 26.Rg3 Qh5 27.Kg2 Nf8 28.Ne2 Ng6 29.h3 Nh4+ 30.Kf1 Kf7 31.Ng1 d4 32.Bc1 gxh3 33.Qe2 Qxe2+ 34.Nxe2 Ng6 35.Rxh3 Bf8 36.Rb3 Rd7 37.Rbd3 Bc5 38.c3 Ba7 39.Be3 Rd5 40.cxd4 Nb4 41.Rb3 a5 42.Bd2".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testUndoTransactionsWithCount() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }
    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
    }

    func testRedoTransactionsWithCount() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
        
    }

}

class GameTransactionTests3: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1.e4 c5 2.Nf3 d6 3.Bb5+ Nd7 4.d4 Nf6 5.Nc3 cxd4 6.Qxd4 e5 7.Qd3 h6 8.Be3 Be7 9.O-O O-O 10.Rad1 a6 11.Bc4 Qc7 12.a4 Nc5 13.Bxc5 Qxc5 14.Nd5 Nxd5 15.Bxd5 Rb8 16.Nd2 Bd7 17.Bb3 b5 18.a5 Rbc8 19.Nf3 Be6 20.Rfe1 Rfd8 21.Re2 Rc7 22.Red2 Rdc8 23.h3 Qb4 24.Bxe6 fxe6 25.Qb3 Rc4 26.Re2 Qxb3 27.cxb3 Rc1 28.Rxc1 Rxc1+ 29.Kh2 Kf7 30.Ne1 Bd8 31.Nd3 Rd1 32.Nb4 Bxa5 33.Nxa6 Rc1 34.b4 Bb6 35.b3 Rc3 36.Ra2 Rxb3 37.Rc2 Bd4 38.Rc7+ Kf6 39.f3 Ra3 40.Rc6 Rc3 41.Rc7 Rxc7 42.Nxc7 Bc3 43.Nxb5 Bxb4 44.Na7 Kf7 45.Kg3 Ke8 46.Kg4 Kd7 47.f4 g6 48.h4 Kc7 49.f5 exf5+ 50.exf5 gxf5+ 51.Kxf5 Kb7 52.Nb5 Kb6 53.Nxd6 Bxd6 54.g4 Kc6 55.g5 hxg5 56.hxg5 Kd5 57.g6 Bf8".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testUndoNTransactions() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }
    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
    }

    func testRedoNTransactions() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            XCTAssertEqual(actual, expected, "for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
        }
        
    }
    
}

class GameTransactionTests4: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e5 6.Ndb5 d6 7.Bg5 a6 8.Na3 Be6 9.Nc4 Rc8 10.Ne3 Be7 11.Bxf6 Bxf6 12.Bc4 O-O 13.Bb3 Nd4 14.O-O Bg5 15.Ncd5 Nxb3 16.axb3 g6 17.Kh1 Bh6 18.Qd3 f5 19.exf5 gxf5 20.f4 Kh8 21.Rad1 Qh4 22.Qe2 exf4 23.Nc4 Bf7 24.Qd3 Bh5 25.Nxd6 Bxd1 26.Nxc8 Bh5 27.Nce7 f3 28.gxf3 Qh3 29.Nf4 Qh4 30.Qd4+ Qf6 31.Qxf6+ Rxf6 32.Nxh5 Rf7 33.Nd5 f4 34.Re1".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    // This test is failing with a missing white King's Knight for index 66.
    func testUndoTransactionsWithCount() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
                break
            }

        }
        
    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
                break
            }

        }

    }

    func testRedoTransactionsWithCount() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
            }

        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
            }

        }
        
    }
    
}

class GameTransactionTests5: XCTestCase {

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

    var moves: [String]!
    var game: Game!
    var delegate: TestDelegate?

    override func setUp() {
        super.setUp()
        moves = try! "1. d4 Nf6 2. Nf3 g6 3. Bg5 Bg7 4. Nbd2 d5 5. e3 O-O 6. c3 Bf5 7. h3 c5 8. dxc5 Qc8 9. Be2 Nbd7 10. b4 b6 11. cxb6 axb6 12. Qb3 Ne4 13. Nxe4 Bxe4 14. O-O Qxc3 15. Nd4 Bxd4 16. exd4 Qxd4 17. Bxe7 Rfc8 18. Bb5 Nf6 19. Qg3 Bc2 20. a4 Ne4 21. Qf4 Qd2 22. Qxd2 Nxd2 23. Rfe1 d4 24. Ra2 Nb3 25. Rb2 d3 26. Bxd3 Bxd3 27. Rxb3 Bc2 28. Rf3 Bxa4 29. Bg5 Bd7 30. Rd3 Be6 31. Bh6 b5 32. Re5 Rcb8 33. Kh2 Rb6 34. g4 Rc8 35. Rc5 Ra8 36. Re3 Rb7 37. Rce5 Rbb8 38. Kg3 Ra1 39. Rd3 Bc4 40. Rd7 Kh8 41. Re4 Rg8 42. Be3 Ra3 43. f3 Rc8 44. g5 Kg8 45. Bc5 Be6 46. Rd1 h5 47. gxh6 Kh7 48. Be3 Ba2 49. Rd7 Rcc3 50. Kf2 Rc2+ 51. Bd2 Rc8 52. Kg3 Rf8 53. Bc1 Ra4 54. Bb2 Rg8 55. Bg7 g5 56. Kg4 Rxb4 57. Rxb4 Be6+ 58. Kxg5 Bxd7 59. Kf6 Ra8 60. Kxf7 Ra4 61. Rb2 Rf4+ 62. Ke7 Bxh3 63. Rxb5 Rxf3 64. Kd6 Re3 65. Rb8 Kg6 66. Rf8 Bf5 67. Rf6+ Kg5 68. Kc5 Rd3 69. Ra6 Be4 70. Kb4 Kh5 71. Rb6 Rd1 72. Re6 Bf5 73. Rf6 Kg5 74. Ra6 Be4 75. Bf8 Rf1 76. Bc5 Rb1+ 77. Kc3 Rc1+ 78. Kd4 Bg6 79. Bf8 Rd1+ 80. Kc3 Rc1+ 81. Kb4 Rb1+ 82. Kc5 Rc1+ 83. Kd6 Rd1+ 84. Ke7 Re1+ 85. Re6 Rxe6+ 86. Kxe6 Bb1 87. Kf7 Bc2 88. Kg7 Kf4 89. Ba3 Bb1 90. Be7 Bc2 91. Bc5 Bb1 92. Bd4 Bc2 93. Bb6 Bd3 94. Kf6 Kg4 95. Bc5 Bb1 96. Bd6 Kh5 97. Bf8 Bd3 98. Kg7 Bb1 99. Bb4 Bc2 100. Bc3 Kh4 101. Bd2 Bb1 102. Kf6 Bc2 103. Bc1 Bb1 104. Bb2 Bc2 105. Kg7 Bd3 106. Bc1 Bb1 107. Be3 Bd3 108. Bg1 Bb1 109. Bd4 Bd3 110. Bf6+ Kh3 111. Be5 Bb1 112. Bc7 Bc2 113. Bd6 Bb1 114. Bf4 Kg2 115. Bc7 Be4 116. Ba5 Kg1 117. Bd2 Bb1 118. Kf6 Bc2 119. Bb4 Bb1 120. Kg5 Bc2 121. Kf4 Bb1 122. Kf3 Bc2 123. Be7 Kh2 124. Bd8 Kh3 125. Kf4 Bb1 126. Kg5 Kg2 127. Ba5 Bc2 128. Bc3 Be4 129. Kf6 Kf1 130. Bd2 Kf2 131. Bg5 Bc2 132. Kg7 Ke2 133. h7 Bxh7".moves()
        game = Game()
        delegate = TestDelegate()
        try! game.execute(sanMoves: moves)
    }

    override func tearDown() {
        moves = nil
        game = nil
        delegate = nil
        super.tearDown()
    }

    func testUndoTransactionsWithCount() {
        game.moveIndex = moves.count
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = moves.count
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
                break
            }

        }

    }

    func testUndoAllTransactionsFromIndex() {
        for index in 1...moves.count {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.undoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
                break
            }

        }

    }

    func testRedoTransactionsWithCount() {

        game.moveIndex = 0
        let initialBoard = game.currentPosition.board

        for count in 1...moves.count {
            game.moveIndex = 0
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redo(count: count)
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for count=\(count)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)\n")
            }

        }

    }

    func testRedoAllTransactionsFromIndex() {

        for index in 0...moves.count-1 {
            game.moveIndex = index
            let initialBoard = game.currentPosition.board
            let delegate = TestDelegate()
            game.delegate = delegate
            game.redoAll()
            let actual = initialBoard.execute(transactions: delegate.transactions)
            let expected = game.currentPosition.board
            if actual != expected {
                XCTFail("for starting at index: \(index)\n\(actual.ascii)\nis not equal to\n\(expected.ascii)")
            }
            
        }
        
    }
    
}
