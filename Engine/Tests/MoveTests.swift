//
//  MoveTests.swift
//  Endgame
//
//  Created by Todd Olsen on 9/23/16.
//
//

import XCTest
@testable import Endgame

class MoveTests: XCTestCase {
    
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

        let (origin, target) = move4.castleSquares()
        XCTAssertEqual(origin, .h8)
        XCTAssertEqual(target, .f8)
    }

}
